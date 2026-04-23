import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/hostel_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final HostelSettings settings;
  SettingsLoaded({required this.settings});
}

class SettingsSaving extends SettingsState {}

class SettingsSaveSuccess extends SettingsState {
  final String message;
  SettingsSaveSuccess({required this.message});
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError({required this.message});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsCubit({required this.settingsRepository}) : super(SettingsInitial());

  Future<void> loadSettings(String hostelId) async {
    emit(SettingsLoading());
    try {
      final settings = await settingsRepository.getSettings(hostelId);
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateProfile(
    String hostelId, {
    required String name,
    required String address,
    required String city,
    required String village,
    required String district,
    required String area,
    required String state,
    required String pincode,
    required String contactNumber,
    required String contactEmail,
    required String description,
    String? propertyTag,
    String? hostelType,
    double? lat,
    double? lng,
  }) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.updateProfile(hostelId, {
        'name': name,
        'address': address,
        'city': city,
        'village': village,
        'district': district,
        'area': area,
        'state': state,
        'pincode': pincode,
        'contactNumber': contactNumber,
        'contactEmail': contactEmail,
        'description': description,
        if (propertyTag != null) 'propertyTag': propertyTag,
        if (hostelType != null) 'hostel_type': hostelType,
        if (lat != null && lng != null)
          'location': {
            'type': 'Point',
            'coordinates': [lng, lat],
          },
      });
      emit(SettingsSaveSuccess(message: 'Profile updated successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateAmenities(
      String hostelId, List<String> enabledAmenities) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.updateAmenities(hostelId, enabledAmenities);
      emit(SettingsSaveSuccess(message: 'Amenities updated successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateHouseRules(
    String hostelId, {
    required String entryTime,
    required String visitorPolicy,
    required String otherRules,
  }) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.updateHouseRules(hostelId, {
        'entryTime': entryTime,
        'visitorPolicy': visitorPolicy,
        'otherRules': otherRules,
      });
      emit(SettingsSaveSuccess(message: 'House rules saved successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateNotifications(
      String hostelId, Map<String, dynamic> data) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.updateNotifications(hostelId, data);
      emit(SettingsSaveSuccess(message: 'Notification settings saved'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateRoomConfiguration(
      String hostelId, Map<String, dynamic> data) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.updateRoomConfiguration(hostelId, data);
      emit(SettingsSaveSuccess(message: 'Room configuration saved'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> updateFullProfile(
    String hostelId, {
    required String name,
    required String address,
    required String city,
    required String village,
    required String district,
    required String area,
    required String state,
    required String pincode,
    required String contactNumber,
    required String contactEmail,
    required String description,
    String? propertyTag,
    String? hostelType,
    double? lat,
    double? lng,
    List<String>? newImagePaths,
    List<String>? existingImages,
  }) async {
    emit(SettingsSaving());
    try {
      // 1. Update profile data FIRST (handles deletions of existing images)
      await settingsRepository.updateProfile(hostelId, {
        'name': name,
        'address': address,
        'city': city,
        'village': village,
        'district': district,
        'area': area,
        'state': state,
        'pincode': pincode,
        'contactNumber': contactNumber,
        'contactEmail': contactEmail,
        'description': description,
        if (propertyTag != null) 'propertyTag': propertyTag,
        if (hostelType != null) 'hostel_type': hostelType,
        if (existingImages != null) 'images': existingImages,
        if (lat != null && lng != null)
          'location': {
            'type': 'Point',
            'coordinates': [lng, lat],
          },
      });

      // 2. Upload NEW images SECOND (appends to the updated list in DB)
      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        await settingsRepository.uploadHostelImages(hostelId, newImagePaths);
      }

      emit(SettingsSaveSuccess(message: 'Profile and images updated successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> uploadHostelImages(String hostelId, List<String> filePaths) async {
    emit(SettingsSaving());
    try {
      await settingsRepository.uploadHostelImages(hostelId, filePaths);
      emit(SettingsSaveSuccess(message: 'Images uploaded successfully'));
      await loadSettings(hostelId);
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }
}
