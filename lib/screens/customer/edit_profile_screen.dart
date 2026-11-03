import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      showMessage('Profile load error: $e');
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('Profile updated successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      showMessage('Error: $e');
    }

    if (mounted) {
      setState(() => isSaving = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveProfile,
                        child: isSaving
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
