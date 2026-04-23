import '../../domain/entities/hostel.dart';

class HostelModel extends Hostel {
  HostelModel({
    required super.id,
    required super.name,
    required super.address,
    required super.floors,
    required super.hostelType,
    super.city,
    super.district,
    super.village,
    super.state,
    super.area,
    super.pincode,
    super.lat,
    super.lng,
    super.occupiedBeds,
    super.totalBeds,
    super.images,
    super.coverImage,
    super.contactNumber,
    super.description,
    super.propertyTag,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final coords = location?['coordinates'] as List<dynamic>?;
    
    return HostelModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      floors: json['floors'] is int
          ? json['floors']
          : int.tryParse(json['floors'].toString()) ?? 0,
      hostelType: json['hostel_type'] ?? json['hostelType'] ?? '',
      propertyTag: json['propertyTag'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      village: json['village'] as String?,
      state: json['state'] as String?,
      area: json['area'] as String?,
      pincode: json['pincode'] as String?,
      lat: coords != null && coords.length >= 2 ? (coords[1] as num).toDouble() : null,
      lng: coords != null && coords.length >= 2 ? (coords[0] as num).toDouble() : null,
      occupiedBeds: json['occupiedBeds'] ?? json['occupied'] ?? 0,
      totalBeds: json['totalBeds'] ?? json['total'] ?? 0,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      coverImage: json['coverImage'] as String?,
      contactNumber: json['contactNumber'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'area': area ?? '',
      'city': city ?? '',
      'district': district ?? '',
      'village': village ?? '',
      'state': state ?? '',
      'pincode': pincode ?? '',
      'floors': floors,
      'hostel_type': hostelType,
      if (propertyTag != null) 'propertyTag': propertyTag,
      if (lat != null && lng != null)
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat],
        },
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (description != null) 'description': description,
      if (images != null) 'images': images,
      if (coverImage != null) 'coverImage': coverImage,
    };
  }
}
