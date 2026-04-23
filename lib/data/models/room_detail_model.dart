import '../../domain/entities/room_detail.dart';

class RoomDetailModel extends RoomDetail {
  RoomDetailModel({
    required super.id,
    required super.hostelId,
    required super.roomTypename,
    required super.floor,
    required super.sharingType,
    required super.roomType,
    required super.rent,
    required super.deposit,
    required super.maintenance,
    required super.isActive,
    required super.isMaster,
    required super.beds,
  });

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) {
    final bedsJson = json['beds'] as List<dynamic>? ?? [];
    return RoomDetailModel(
      id: json['_id'] ?? json['roomId'] ?? '',
      hostelId: json['hostel'] is Map ? json['hostel']['_id'] ?? '' : json['hostel'] ?? '',
      roomTypename: json['roomTypename'] ?? '',
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      sharingType: json['sharingType'] ?? '',
      roomType: json['roomType'] ?? '',
      rent: (json['rent'] as num?)?.toDouble() ?? 0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      maintenance: (json['maintenance'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] ?? true,
      isMaster: json['isMaster'] ?? false,
      beds: bedsJson.map((b) => BedInfo(
        bedNumber: b['bedNumber']?.toString() ?? '',
        status: b['status'] ?? 'FREE',
      )).toList(),
    );
  }

  Map<String, dynamic> toCreateJson(String hostelId) {
    return {
      'hostelId': hostelId,
      'roomTypename': roomTypename,
      'floor': floor,
      'sharingType': sharingType,
      'roomType': roomType,
      'rent': rent,
      'deposit': deposit,
      'maintenance': maintenance,
      'isMaster': isMaster,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'roomTypename': roomTypename,
      'floor': floor,
      'sharingType': sharingType,
      'roomType': roomType,
      'rent': rent,
      'deposit': deposit,
      'maintenance': maintenance,
      'isActive': isActive,
      'isMaster': isMaster,
    };
  }
}
