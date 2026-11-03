import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  final String collection = 'products';

  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  void openProductForm(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(productId: id, productData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text('No products added yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: data['imageUrl'] ?? '',
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.watch, size: 35),
                    ),
                  ),
                  title: Text(
                    data['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Rs. ${data['price'] ?? 0}\n'
                    'Stock: ${data['stock'] ?? 0}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        openProductForm(context, id: doc.id, data: data);
                      }

                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete Product?'),
                            content: const Text(
                              'Are you sure you want to delete this product?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await deleteProduct(doc.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Product deleted'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => const [
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

class ProductFormScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? productData;

  const ProductFormScreen({super.key, this.productId, this.productData});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController brandController;
  late final TextEditingController priceController;
  late final TextEditingController stockController;
  late final TextEditingController imageController;

  String? selectedCategory;
  bool isFeatured = false;
  bool isBestSeller = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    final data = widget.productData ?? {};

    titleController = TextEditingController(text: data['title'] ?? '');
    descriptionController = TextEditingController(
      text: data['description'] ?? '',
    );
    brandController = TextEditingController(text: data['brand'] ?? '');
    priceController = TextEditingController(
      text: data['price']?.toString() ?? '',
    );
    stockController = TextEditingController(
      text: data['stock']?.toString() ?? '',
    );
    imageController = TextEditingController(text: data['imageUrl'] ?? '');

    selectedCategory = data['category'];
    isFeatured = data['isFeatured'] ?? false;
    isBestSeller = data['isBestSeller'] ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    brandController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final product = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'brand': brandController.text.trim(),
        'category': selectedCategory,
        'price': double.parse(priceController.text.trim()),
        'stock': int.parse(stockController.text.trim()),
        'imageUrl': imageController.text.trim(),
        'isFeatured': isFeatured,
        'isBestSeller': isBestSeller,
        'images': widget.productData?['images'] ?? [],
      };

      final ref = FirebaseFirestore.instance.collection('products');

      if (widget.productId == null) {
        product.addAll({
          'rating': 0,
          'reviewCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await ref.add(product);
      } else {
        await ref.doc(widget.productId).update(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId == null
                  ? 'Product added successfully'
                  : 'Product updated successfully',
            ),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            field('Product Name', titleController),
            field('Description', descriptionController, maxLines: 4),
            field('Brand', brandController),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                final categories = snapshot.data?.docs ?? [];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: DropdownButtonFormField<String>(
                    initialValue:
                        categories.any(
                          (doc) =>
                              doc.id == selectedCategory ||
                              doc.get('name') == selectedCategory,
                        )
                        ? selectedCategory
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((doc) {
                      final name = doc.data() as Map<String, dynamic>;

                      final categoryName = name['name']?.toString() ?? '';

                      return DropdownMenuItem<String>(
                        value: categoryName,
                        child: Text(categoryName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                    validator: (value) =>
                        value == null ? 'Select category' : null,
                  ),
                );
              },
            ),

            field('Price', priceController, keyboard: TextInputType.number),
            field('Stock', stockController, keyboard: TextInputType.number),
            field('Image URL', imageController, keyboard: TextInputType.url),

            if (imageController.text.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageController.text,
                height: 150,
                fit: BoxFit.contain,
                errorWidget: (_, _, _) => const Text('Image URL is invalid'),
              ),

            SwitchListTile(
              title: const Text('Featured Product'),
              value: isFeatured,
              onChanged: (value) => setState(() => isFeatured = value),
            ),

            SwitchListTile(
              title: const Text('Best Seller'),
              value: isBestSeller,
              onChanged: (value) => setState(() => isBestSeller = value),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saving ? null : saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.productId == null
                          ? 'Save Product'
                          : 'Update Product',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
