class SupportMessageModel {
  final String id;
  final String userId;
  final String message;
  final String sender;
  final DateTime? createdAt;

  SupportMessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.sender,
    this.createdAt,
  });

  factory SupportMessageModel.fromMap(String id, Map<String, dynamic> data) {
    return SupportMessageModel(
      id: id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      sender: data['sender'] ?? 'user',
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as dynamic).toDate(),
    );
  }
}
