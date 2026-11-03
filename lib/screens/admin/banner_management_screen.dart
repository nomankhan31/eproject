import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/banner_model.dart';
import '../../services/banner_service.dart';

class BannerManagementScreen extends StatefulWidget {
  const BannerManagementScreen({super.key});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  final BannerService service = BannerService();

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final imageController = TextEditingController();
  final orderController = TextEditingController();

  bool isActive = true;
  bool saving = false;

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    imageController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> showBannerDialog({BannerModel? banner}) async {
    final formKey = GlobalKey<FormState>();

    titleController.text = banner?.title ?? '';
    subtitleController.text = banner?.subtitle ?? '';
    imageController.text = banner?.imageUrl ?? '';
    orderController.text = (banner?.sortOrder ?? 0).toString();
    isActive = banner?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(banner == null ? 'Add Banner' : 'Edit Banner'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Banner Title',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter title'
                            : null,
                      ),
                      TextFormField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle',
                        ),
                      ),
                      TextFormField(
                        controller: imageController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                        ),
                        validator: (v) {
                          final uri = Uri.tryParse(v?.trim() ?? '');
                          if (uri == null ||
                              !uri.hasScheme ||
                              !['http', 'https'].contains(uri.scheme) ||
                              uri.host.isEmpty) {
                            return 'Enter a valid image URL';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: orderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Display Order',
                        ),
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Enter a valid number'
                            : null,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() => saving = true);

                          try {
                            final title = titleController.text.trim();
                            final subtitle = subtitleController.text.trim();
                            final image = imageController.text.trim();
                            final order = int.parse(
                              orderController.text.trim(),
                            );

                            if (banner == null) {
                              await service.addBanner(
                                title: title,
                                subtitle: subtitle,
                                imageUrl: image,
                                sortOrder: order,
                              );

                              if (!isActive) {
                                final query = await service
                                    .getAllBanners()
                                    .first;
                                final created = query.firstWhere(
                                  (b) =>
                                      b.title == title && b.imageUrl == image,
                                );
                                await service.updateBanner(
                                  id: created.id,
                                  title: title,
                                  subtitle: subtitle,
                                  imageUrl: image,
                                  sortOrder: order,
                                  isActive: false,
                                );
                              }
                            } else {
                              await service.updateBanner(
                                id: banner.id,
                                title: title,
                                subtitle: subtitle,
                                imageUrl: image,
                                sortOrder: order,
                                isActive: isActive,
                              );
                            }

                            if (!mounted) return;

                            // ignore: use_build_context_synchronously
                            Navigator.pop(dialogContext);
                            showMessage('Banner saved successfully');
                          } catch (e) {
                            showMessage('Error: $e');
                          } finally {
                            if (mounted) {
                              setState(() => saving = false);
                            }
                          }
                        },
                  child: Text(saving ? 'Saving...' : 'Save Banner'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteBanner(BannerModel banner) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner?'),
        content: Text('Delete "${banner.title}"?'),
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
      await service.deleteBanner(banner.id);
      showMessage('Banner deleted');
    } catch (e) {
      showMessage('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        onPressed: () => showBannerDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Banner'),
      ),
      body: StreamBuilder<List<BannerModel>>(
        stream: service.getAllBanners(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load banners'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final banners = snapshot.data!;

          if (banners.isEmpty) {
            return const Center(child: Text('No banners added yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const SizedBox(
                        height: 100,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                    ListTile(
                      title: Text(banner.title),
                      subtitle: Text(
                        '${banner.subtitle}\nOrder: ${banner.sortOrder} | '
                        '${banner.isActive ? 'Active' : 'Inactive'}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showBannerDialog(banner: banner);
                          } else if (value == 'delete') {
                            deleteBanner(banner);
                          } else if (value == 'toggle') {
                            service.updateBanner(
                              id: banner.id,
                              title: banner.title,
                              subtitle: banner.subtitle,
                              imageUrl: banner.imageUrl,
                              sortOrder: banner.sortOrder,
                              isActive: !banner.isActive,
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(
                              banner.isActive ? 'Deactivate' : 'Activate',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
