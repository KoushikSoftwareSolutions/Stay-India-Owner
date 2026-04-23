class Hostel {
  final String id;
  final String name;
  final String address;
  final int floors;
  final String hostelType;
  final String? city;
  final String? district;
  final String? village;
  final String? state;
  final String? area;
  final String? pincode;
  final double? lat;
  final double? lng;
  final int? occupiedBeds;
  final int? totalBeds;

  final List<String>? images;
  final String? coverImage;
  final String? contactNumber;
  final String? description;
  final String? propertyTag;

  Hostel({
    required this.id,
    required this.name,
    required this.address,
    required this.floors,
    required this.hostelType,
    this.city,
    this.district,
    this.village,
    this.state,
    this.area,
    this.pincode,
    this.lat,
    this.lng,
    this.occupiedBeds,
    this.totalBeds,
    this.images,
    this.coverImage,
    this.contactNumber,
    this.description,
    this.propertyTag,
  });
}
