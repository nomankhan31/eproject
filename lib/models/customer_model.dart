class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isBlocked;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isBlocked,
    this.createdAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> data) {
    final dateValue = data['createdAt'];

    DateTime? date;

    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue != null) {
      date = dateValue.toDate() as DateTime;
    }

    return CustomerModel(
      id: id,
      name: data['name']?.toString() ?? 'No Name',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      isBlocked: data['isBlocked'] == true,
      createdAt: date,
    );
  }
}
