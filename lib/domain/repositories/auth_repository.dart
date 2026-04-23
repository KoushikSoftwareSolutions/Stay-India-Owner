import '../../domain/entities/owner.dart';

abstract class AuthRepository {
  Future<String?> requestOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);

  Future<bool> completeProfile(Map<String, dynamic> data);
  Future<bool> updateProfile(Map<String, dynamic> data);
  Future<Owner> getMe();
}

