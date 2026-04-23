class Staff {
  final String id;
  final String hostelId;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final List<String>? permissions;
  final bool isActive;
  final String createdAt;

  const Staff({
    required this.id,
    required this.hostelId,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.permissions,
    required this.isActive,
    required this.createdAt,
  });
}
