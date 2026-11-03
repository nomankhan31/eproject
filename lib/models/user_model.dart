class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
  }
}
