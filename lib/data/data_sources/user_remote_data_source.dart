import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String? dob;
  final String? gender;
  final String? avatar;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    this.dob,
    this.gender,
    this.avatar,
  });

  String get fullName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

abstract class UserRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
  });
  Future<void> deleteAccount();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.userProfile);
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      }
      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error loading profile';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  @override
  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
  }) async {
    try {
      final body = <String, dynamic>{
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
      };
      final response = await dio.put(ApiConstants.userProfile, data: body);
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error updating profile';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await dio.delete(ApiConstants.userDeleteAccount);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete account');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error deleting account';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }
}
