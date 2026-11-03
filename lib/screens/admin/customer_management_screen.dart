import 'package:flutter/material.dart';

import '../../models/customer_model.dart';
import '../../services/customer_service.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final CustomerService _service = CustomerService();

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<CustomerModel>>(
              stream: _service.getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading customers'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = snapshot.data ?? [];

                final filteredCustomers = customers.where((customer) {
                  return customer.name.toLowerCase().contains(searchQuery) ||
                      customer.email.toLowerCase().contains(searchQuery) ||
                      customer.phone.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.email),
                            Text(customer.phone),
                            const SizedBox(height: 5),
                            Text(
                              customer.isBlocked ? 'Blocked' : 'Active',
                              style: TextStyle(
                                color: customer.isBlocked
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        onTap: () {
                          _showCustomerDetails(customer);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Customer Details'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${customer.name}'),
              const SizedBox(height: 8),
              Text('Email: ${customer.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${customer.phone}'),
              const SizedBox(height: 8),
              Text('Status: ${customer.isBlocked ? 'Blocked' : 'Active'}'),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customer.isBlocked ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                try {
                  await _service.updateBlockStatus(
                    customer.id,
                    !customer.isBlocked,
                  );

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        customer.isBlocked
                            ? 'Customer unblocked'
                            : 'Customer blocked',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },

              child: Text(customer.isBlocked ? 'Unblock' : 'Block'),
            ),
          ],
        );
      },
    );
  }
}
