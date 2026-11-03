class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isActive;
  final int sortOrder;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isActive,
    required this.sortOrder,
  });

  factory BannerModel.fromMap(String id, Map<String, dynamic> data) {
    return BannerModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
