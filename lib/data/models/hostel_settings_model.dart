import '../../domain/entities/hostel_settings.dart';

class SettingsProfileModel extends SettingsProfile {
  const SettingsProfileModel({
    required super.name,
    required super.address,
    required super.contactNumber,
    required super.contactEmail,
    required super.city,
    required super.village,
    required super.area,
    required super.district,
    required super.state,
    required super.pincode,
    required super.description,
    required super.hostelType,
    super.propertyTag,
    super.lat,
    super.lng,
  });

  factory SettingsProfileModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final coords = location?['coordinates'] as List<dynamic>?;
    final hostelTypeRaw = json['hostel_type'] ?? json['hostelType'] ?? 'men';

    return SettingsProfileModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      city: json['city'] ?? '',
      village: json['village'] ?? '',
      area: json['area'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      description: json['description'] ?? '',
      hostelType: hostelTypeRaw,
      propertyTag: json['propertyTag'] as String?,
      lat: coords != null && coords.length >= 2 ? (coords[1] as num).toDouble() : null,
      lng: coords != null && coords.length >= 2 ? (coords[0] as num).toDouble() : null,
    );
  }
}

class AmenityItemModel extends AmenityItem {
  const AmenityItemModel({required super.name, required super.enabled});

  factory AmenityItemModel.fromJson(Map<String, dynamic> json) {
    return AmenityItemModel(
      name: json['name'] ?? '',
      enabled: json['enabled'] == true,
    );
  }
}

class HouseRulesModel extends HouseRules {
  const HouseRulesModel({
    required super.entryTime,
    required super.visitorPolicy,
    required super.otherRules,
  });

  factory HouseRulesModel.fromJson(Map<String, dynamic> json) {
    return HouseRulesModel(
      entryTime: json['entryTime'] ?? '',
      visitorPolicy: json['visitorPolicy'] ?? '',
      otherRules: json['otherRules'] ?? '',
    );
  }
}

class HostelSettingsModel extends HostelSettings {
  const HostelSettingsModel({
    required super.profile,
    required super.amenities,
    required super.houseRules,
    super.images,
    super.coverImage,
  });

  factory HostelSettingsModel.fromJson(Map<String, dynamic> json) {
    final profileData = json['profile'] as Map<String, dynamic>? ?? {};
    final amenitiesData = json['amenities'] as List<dynamic>? ?? [];
    final houseRulesData = json['houseRules'] as Map<String, dynamic>? ?? {};

    return HostelSettingsModel(
      profile: SettingsProfileModel.fromJson(profileData),
      amenities: amenitiesData
          .map((a) => AmenityItemModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      houseRules: HouseRulesModel.fromJson(houseRulesData),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      coverImage: json['coverImage'] as String?,
    );
  }
}
