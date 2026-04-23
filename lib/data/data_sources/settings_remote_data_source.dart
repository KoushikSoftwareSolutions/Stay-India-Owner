import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/hostel_settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<HostelSettingsModel> getSettings(String hostelId);
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data);
  Future<void> updateAmenities(String hostelId, List<String> enabledAmenities);
  Future<void> updateHouseRules(String hostelId, Map<String, dynamic> data);
  Future<void> updateNotifications(String hostelId, Map<String, dynamic> data);
  Future<void> updateRoomConfiguration(String hostelId, Map<String, dynamic> data);
  Future<void> uploadHostelImages(String hostelId, List<String> filePaths);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<HostelSettingsModel> getSettings(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.settings}/$hostelId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return HostelSettingsModel.fromJson(data);
      }
      throw Exception('Failed to load settings');
    } catch (e) {
      throw Exception('Error loading settings: $e');
    }
  }

  @override
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/profile',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  @override
  Future<void> updateAmenities(
      String hostelId, List<String> enabledAmenities) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/amenities',
        data: {'amenities': enabledAmenities},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update amenities');
      }
    } catch (e) {
      throw Exception('Error updating amenities: $e');
    }
  }

  @override
  Future<void> updateHouseRules(
      String hostelId, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/house-rules',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update house rules');
      }
    } catch (e) {
      throw Exception('Error updating house rules: $e');
    }
  }

  @override
  Future<void> updateNotifications(
      String hostelId, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/notifications',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update notification settings');
      }
    } catch (e) {
      throw Exception('Error updating notification settings: $e');
    }
  }

  @override
  Future<void> updateRoomConfiguration(
      String hostelId, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.settings}/$hostelId/room-configuration',
        data: data,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update room configuration');
      }
    } catch (e) {
      throw Exception('Error updating room configuration: $e');
    }
  }

  @override
  Future<void> uploadHostelImages(String hostelId, List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(path),
          ),
        );
      }
      formData.fields.add(const MapEntry('folder', 'hostels'));

      final response = await dio.post(
        '${ApiConstants.hostels}/$hostelId/images',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload images');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }
}
