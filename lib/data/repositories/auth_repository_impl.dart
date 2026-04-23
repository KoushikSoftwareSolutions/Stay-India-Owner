import '../../domain/entities/owner.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String?> requestOtp(String phone) {
    return remoteDataSource.requestOtp(phone);
  }


  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) {
    return remoteDataSource.verifyOtp(phone, otp);
  }

  @override
  Future<bool> completeProfile(Map<String, dynamic> data) {
    return remoteDataSource.completeProfile(data);
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> data) {
    return remoteDataSource.updateProfile(data);
  }

  @override
  Future<Owner> getMe() {
    return remoteDataSource.getMe();
  }
}
