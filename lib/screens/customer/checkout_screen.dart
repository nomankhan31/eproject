import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:watchhub/screens/customer/rder_confirmation_screen.dart';

import '../../services/order_service.dart';
import '../../providers/cart_provider.dart';
import 'address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final OrderService orderService = OrderService();

  String paymentMethod = 'COD';
  String? selectedAddressId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCustomerInfo();
  }

  Future<void> loadCustomerInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;

        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';

        setState(() {});
      }
    } catch (e) {
      debugPrint('Customer info error: $e');
    }
  }

  void selectAddress(String id, Map<String, dynamic> data) {
    setState(() {
      selectedAddressId = id;
      addressController.text =
          '${data['address'] ?? ''}, ${data['city'] ?? ''}';
      phoneController.text = data['phone'] ?? '';
    });
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    if (widget.cartItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final items = widget.cartItems.map((item) {
        return {
          'productId': item['id'],
          'title': item['title'],
          'price': item['price'],
          'quantity': item['quantity'],
          'imageUrl': item['imageUrl'] ?? '',
        };
      }).toList();

      final orderId = await orderService.createOrder(
        userId: user.uid,
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        items: items,
        totalAmount: widget.totalAmount,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      // Clear cart after successful order creation.
      context.read<CartProvider>().clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            orderId: orderId,
            totalAmount: widget.totalAmount,
            paymentMethod: paymentMethod,
            deliveryAddress: addressController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Order failed: $e')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    final addressesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Information',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your name'
                    : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter phone number'
                    : null,
              ),

              const SizedBox(height: 25),

              const Text(
                'Select Saved Address',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: addressesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Unable to load saved addresses.');
                  }

                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text(
                      'No saved addresses. Enter your address below.',
                    );
                  }

                  final validIds = docs.map((doc) => doc.id).toSet();

                  if (selectedAddressId != null &&
                      !validIds.contains(selectedAddressId)) {
                    selectedAddressId = null;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedAddressId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Choose Address',
                          border: OutlineInputBorder(),
                        ),
                        items: docs.map((doc) {
                          final data = doc.data();

                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(
                              '${data['address'] ?? ''}, ${data['city'] ?? ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id == null) return;

                          final selectedDoc = docs.firstWhere(
                            (doc) => doc.id == id,
                          );

                          selectAddress(id, selectedDoc.data());
                        },
                      ),

                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_location_alt),
                        label: const Text('Manage Addresses'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter your complete address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter delivery address'
                    : null,
              ),

              const SizedBox(height: 25),

              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              RadioListTile<String>(
                title: const Text('Cash on Delivery'),
                subtitle: const Text('Pay when your order arrives'),
                secondary: const Icon(Icons.money, color: Colors.green),
                value: 'COD',
                // ignore: deprecated_member_use
                groupValue: paymentMethod,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),

              RadioListTile<String>(
                title: const Text('JazzCash'),
                subtitle: const Text('Manual payment verification'),
                secondary: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.red,
                ),
                value: 'JazzCash',
                // ignore: deprecated_member_use
                groupValue: paymentMethod,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),

              RadioListTile<String>(
                title: const Text('Easypaisa'),
                subtitle: const Text('Manual payment verification'),
                secondary: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                ),
                value: 'Easypaisa',
                // ignore: deprecated_member_use
                groupValue: paymentMethod,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => paymentMethod = value!);
                },
              ),

              const Divider(height: 30),

              if (paymentMethod != 'COD')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Manual payment selected. Payment will remain pending until the admin verifies it.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Place Order',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
