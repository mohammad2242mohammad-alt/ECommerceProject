class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.role,
    this.name,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String phone;
  final String role;
  final String? name;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString(),
      isActive: json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
