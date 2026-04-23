class SettingsProfile {
  final String name;
  final String address;
  final String contactNumber;
  final String contactEmail;
  final String city;
  final String village;
  final String area;
  final String district;
  final String state;
  final String pincode;
  final String description;
  final double? lat;
  final double? lng;
  final String hostelType;
  final String? propertyTag;

  const SettingsProfile({
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.contactEmail,
    required this.city,
    required this.village,
    required this.area,
    required this.district,
    required this.state,
    required this.pincode,
    required this.description,
    required this.hostelType,
    this.propertyTag,
    this.lat,
    this.lng,
  });
}

class AmenityItem {
  final String name;
  final bool enabled;

  const AmenityItem({required this.name, required this.enabled});
}

class HouseRules {
  final String entryTime;
  final String visitorPolicy;
  final String otherRules;

  const HouseRules({
    required this.entryTime,
    required this.visitorPolicy,
    required this.otherRules,
  });
}

class HostelSettings {
  final SettingsProfile profile;
  final List<AmenityItem> amenities;
  final HouseRules houseRules;
  final List<String>? images;
  final String? coverImage;

  const HostelSettings({
    required this.profile,
    required this.amenities,
    required this.houseRules,
    this.images,
    this.coverImage,
  });
}
