import '../../domain/entities/occupancy_summary.dart';

class OccupancyModel extends Occupancy {
  final List<FloorDataModel> floors;

  OccupancyModel({
    required super.totalBeds,
    required super.freeBeds,
    required super.occupiedBeds,
    required super.noticeBeds,
    required super.awayBeds,
    required super.reservedBeds,
    required this.floors,
  });

  factory OccupancyModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final floorsJson = json['floors'] as List<dynamic>? ?? [];

    return OccupancyModel(
      totalBeds: summary['totalBeds'] ?? 0,
      freeBeds: summary['freeBeds'] ?? 0,
      occupiedBeds: summary['occupiedBeds'] ?? 0,
      noticeBeds: summary['noticeBeds'] ?? 0,
      awayBeds: summary['awayBeds'] ?? 0,
      reservedBeds: summary['reservedBeds'] ?? 0,
      floors: floorsJson.map((f) => FloorDataModel.fromJson(f)).toList(),
    );
  }
}

class FloorDataModel extends FloorData {
  FloorDataModel({
    required super.floorName,
    required super.bedInfo,
    required super.rooms,
  });

  factory FloorDataModel.fromJson(Map<String, dynamic> json) {
    final roomsJson = json['rooms'] as List<dynamic>? ?? [];
    final floorNum = json['floor'];
    final floorLabel = floorNum == 0 ? 'Ground Floor' : 'Floor $floorNum';

    // Compute bed counts for the bedInfo subtitle
    int totalBeds = 0, freeBeds = 0;
    for (final r in roomsJson) {
      final beds = (r as Map)['beds'] as List<dynamic>? ?? [];
      totalBeds += beds.length;
      freeBeds += beds.where((b) => (b as Map)['status'] == 'FREE').length;
    }

    return FloorDataModel(
      floorName: floorLabel,
      bedInfo: '$freeBeds/$totalBeds beds free',
      rooms: roomsJson.map((r) => RoomModel.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }
}

class RoomModel extends Room {
  RoomModel({
    required super.id,
    required super.roomNumber,
    required super.sharingType,
    required super.occupancy,
    required super.tenantImages,
    required super.beds,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final bedsJson = json['beds'] as List<dynamic>? ?? [];
    final occupied =
        bedsJson.where((b) => (b as Map)['status'] != 'FREE').length;
    final total = bedsJson.length;

    final List<BedInfo> beds = bedsJson.map((b) {
      final map = b as Map<String, dynamic>;
      final tenant = map['tenant'] as Map<String, dynamic>?;
      
      String? tenantName;
      if (tenant != null) {
        final firstName = tenant['firstName']?.toString() ?? '';
        final lastName = tenant['lastName']?.toString() ?? '';
        tenantName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
        if (tenantName.isEmpty) tenantName = tenant['name']?.toString();
      }

      return BedInfo(
        bedNumber: map['bedNumber']?.toString() ?? '',
        status: map['status']?.toString() ?? 'FREE',
        tenantName: tenantName,
        tenantAvatar: tenant?['avatar']?.toString() ?? tenant?['userProfile']?['avatar']?.toString(),
        tenantId: tenant?['_id']?.toString() ?? tenant?['id']?.toString(),
      );
    }).toList();

    // profileImage is not returned by the occupancy endpoint; use empty strings as placeholders
    final tenantImages = bedsJson
        .where((b) => (b as Map)['tenant'] != null)
        .map((_) => '')
        .toList()
        .cast<String>();

    return RoomModel(
      id: json['_id'] ?? json['roomId'] ?? '',
      roomNumber: json['roomTypename'] ?? '',
      sharingType: json['sharingType'] ?? '',
      occupancy: '$occupied/$total beds',
      tenantImages: tenantImages,
      beds: beds,
    );
  }
}
