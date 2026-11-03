import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController addressController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get addressCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('addresses');

  Future<void> saveAddress({String? addressId}) async {
    if (addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final data = {
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'phone': phoneController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (addressId == null) {
        await addressCollection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await addressCollection.doc(addressId).update(data);
      }

      addressController.clear();
      cityController.clear();
      phoneController.clear();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showAddressDialog({
    String? addressId,
    String address = '',
    String city = '',
    String phone = '',
  }) {
    addressController.text = address;
    cityController.text = city;
    phoneController.text = phone;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(addressId == null ? 'Add Address' : 'Edit Address'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Full Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addressController.clear();
                cityController.clear();
                phoneController.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                saveAddress(addressId: addressId);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAddress(String id) async {
    await addressCollection.doc(id).delete();
  }

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () => showAddressDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: addressCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data!.docs;

          if (addresses.isEmpty) {
            return const Center(child: Text('No saved addresses yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final doc = addresses[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(data['address'] ?? ''),
                  subtitle: Text(
                    '${data['city'] ?? ''}\n'
                    '${data['phone'] ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showAddressDialog(
                          addressId: doc.id,
                          address: data['address'] ?? '',
                          city: data['city'] ?? '',
                          phone: data['phone'] ?? '',
                        );
                      } else if (value == 'delete') {
                        deleteAddress(doc.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
