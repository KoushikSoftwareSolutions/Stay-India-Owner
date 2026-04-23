import '../../domain/entities/owner.dart';

/// Data model for the GET /auth/me response.
/// Adjust field names below if your backend uses different keys
/// (e.g. "_id" instead of "id", "fullName" instead of "name").
class OwnerModel extends Owner {
  const OwnerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.avatar,
    super.isProfileComplete,
    super.bedLimit = 10,
    super.plan = 'free',
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    // Backend returns firstName + lastName separately
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullName = (json['name'] ?? json['fullName'] ?? '').toString().trim();
    final name = fullName.isNotEmpty
        ? fullName
        : [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final ownerProfile = json['ownerProfile'] ?? {};
    final subscription = ownerProfile['subscription'] ?? {};

    return OwnerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: name,
      phone: (json['phone'] ?? json['mobile'] ?? '').toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      isProfileComplete: json['isProfileComplete'] == true || json['is_profile_complete'] == true,
      bedLimit: subscription['bedLimit'] is int ? subscription['bedLimit'] : int.tryParse(subscription['bedLimit']?.toString() ?? '') ?? 10,
      plan: subscription['plan']?.toString() ?? 'free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
    };
  }
}
