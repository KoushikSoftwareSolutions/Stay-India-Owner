import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/token_storage.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/owner.dart';
import '../models/owner_model.dart';
import '../../core/error/app_exceptions.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

abstract class AuthRemoteDataSource {
  Future<String?> requestOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);

  Future<bool> completeProfile(Map<String, dynamic> data);
  Future<bool> updateProfile(Map<String, dynamic> data);
  Future<Owner> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.tokenStorage,
  });

  String _sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^91'), '');
  }

  @override
  Future<String?> requestOtp(String phone) async {
    final sanitizedPhone = _sanitizePhone(phone);
    AppLogger.info('Requesting OTP for: $sanitizedPhone');
    
    final response = await dio.post(
      ApiConstants.requestOtp,
      data: {'phone': sanitizedPhone, 'role': 'OWNER'},
    );

    if (response.statusCode == 200) {
      AppLogger.success('OTP requested successfully for $sanitizedPhone');
      final data = response.data;
      if (data is Map && data['data'] != null && data['data']['otp'] != null) {
        return data['data']['otp'].toString();
      }
      return "";
    } else {
      String message = 'Failed to request OTP';
      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      throw ServerException(
        message: message,
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final sanitizedPhone = _sanitizePhone(phone);
    AppLogger.info('Verifying OTP for: $sanitizedPhone');
    
    final response = await dio.post(
      ApiConstants.verifyOtp,
      data: {
        'phone': sanitizedPhone,
        'otp': otp,
        'role': 'OWNER',
      },
    );

    if (response.statusCode == 200) {
      AppLogger.success('OTP verified successfully');
      final data = response.data;
      final raw = data['data'] is Map ? data['data'] : data;
      final responseData = Map<String, dynamic>.from(raw as Map);
      
      final token = responseData['token'] as String? ?? responseData['accessToken'] as String?;
      if (token != null && token.isNotEmpty) {
        await tokenStorage.saveToken(token);
        await tokenStorage.savePhone(sanitizedPhone);
      }

      return {
        'success': true,
        'isNewUser': responseData['isNewUser'] == true,
        'phone': sanitizedPhone,
        'user': responseData['user'],
      };
    } else {
      String message = 'Verification failed';
      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      throw AuthException(
        message: message,
      );
    }
  }

  @override
  Future<bool> completeProfile(Map<String, dynamic> data) async {
    AppLogger.info('Completing user profile');
    
    try {
      final formDataMap = Map<String, dynamic>.from(data);
      final String? imagePath = formDataMap.remove('avatar');
      
      if (imagePath != null && imagePath.isNotEmpty) {
        final formData = FormData.fromMap(formDataMap);
        try {
          final File file = File(imagePath);
          // Always use .jpg for the compressed output to satisfy the library requirements
          final String targetPath = p.join((await getTemporaryDirectory()).path, "temp_${p.basenameWithoutExtension(imagePath)}.jpg");
          
          AppLogger.info('Compressing image: $imagePath -> $targetPath');
          
          final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 70,
            minWidth: 1024,
            minHeight: 1024,
          );

          if (compressedFile != null) {
            formData.files.add(MapEntry(
              'avatar',
              await MultipartFile.fromFile(compressedFile.path),
            ));
          } else {
            formData.files.add(MapEntry(
              'avatar',
              await MultipartFile.fromFile(imagePath),
            ));
          }
        } catch (e) {
          AppLogger.error('Image compression failed, uploading original: $e');
          formData.files.add(MapEntry(
            'avatar',
            await MultipartFile.fromFile(imagePath),
          ));
        }

        final response = await dio.post(
          ApiConstants.userCompleteProfile,
          data: formData,
          options: Options(headers: {'x-upload-folder': 'profiles'}),
        );

        return response.statusCode == 200 || 
               response.statusCode == 201 || 
               response.statusCode == 409;
      } else {
        // No image: Use standard JSON request for maximum reliability
        final response = await dio.post(
          ApiConstants.userCompleteProfile,
          data: formDataMap,
        );

        return response.statusCode == 200 || 
               response.statusCode == 201 || 
               response.statusCode == 409;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) return true;
      rethrow;
    } catch (e) {
      AppLogger.error('Error in completeProfile: $e');
      return false;
    }
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    AppLogger.info('Updating user profile');
    final response = await dio.put('/users/profile', data: data);
    return response.statusCode == 200;
  }

  @override
  Future<Owner> getMe() async {
    AppLogger.info('Fetching owner profile');
    final response = await dio.get(ApiConstants.getMe);
    
    if (response.statusCode == 200) {
      final data = response.data;
      var ownerJson = (data is Map && data.containsKey('data') && data['data'] is Map)
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
          
      if (ownerJson.containsKey('user') && ownerJson['user'] is Map) {
        ownerJson = ownerJson['user'] as Map<String, dynamic>;
      }
      
      return OwnerModel.fromJson(ownerJson);
    } else {
      throw ServerException(message: 'Failed to fetch owner profile');
    }
  }
}
