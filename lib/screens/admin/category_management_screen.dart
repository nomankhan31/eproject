import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/category_model.dart';
import '../../services/category_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _service = CategoryService();

  Future<void> _showCategoryDialog({CategoryModel? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');

    final imageController = TextEditingController(
      text: category?.imageUrl ?? '',
    );

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(category == null ? 'Add Category' : 'Edit Category'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() => saving = true);

                          try {
                            if (category == null) {
                              await _service.addCategory(
                                name: nameController.text,
                                imageUrl: imageController.text,
                              );
                            } else {
                              await _service.updateCategory(
                                id: category.id,
                                name: nameController.text,
                                imageUrl: imageController.text,
                              );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    category == null
                                        ? 'Category added successfully'
                                        : 'Category updated successfully',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => saving = false);

                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(category == null ? 'Save' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    imageController.dispose();
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteCategory(category.id);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Category deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: _service.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load categories'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;

          if (categories.isEmpty) {
            return const Center(child: Text('No categories added yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: category.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.category, size: 35),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCategoryDialog(category: category);
                      } else if (value == 'delete') {
                        _deleteCategory(category);
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
