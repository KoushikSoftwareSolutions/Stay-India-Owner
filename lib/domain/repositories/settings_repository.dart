import '../entities/hostel_settings.dart';

abstract class SettingsRepository {
  Future<HostelSettings> getSettings(String hostelId);
  Future<void> updateProfile(String hostelId, Map<String, dynamic> data);
  Future<void> updateAmenities(String hostelId, List<String> enabledAmenities);
  Future<void> updateHouseRules(String hostelId, Map<String, dynamic> data);
  Future<void> updateNotifications(String hostelId, Map<String, dynamic> data);
  Future<void> updateRoomConfiguration(String hostelId, Map<String, dynamic> data);
  Future<void> uploadHostelImages(String hostelId, List<String> filePaths);
}
