class Occupancy {
  final int totalBeds;
  final int freeBeds;
  final int occupiedBeds;
  final int noticeBeds;
  final int awayBeds;
  final int reservedBeds;

  Occupancy({
    required this.totalBeds,
    required this.freeBeds,
    required this.occupiedBeds,
    required this.noticeBeds,
    required this.awayBeds,
    required this.reservedBeds,
  });
}

class FloorData {
  final String floorName;
  final String bedInfo; // e.g. "5 / 9 beds"
  final List<Room> rooms;

  FloorData({
    required this.floorName,
    required this.bedInfo,
    required this.rooms,
  });
}

class Room {
  final String id;
  final String roomNumber;
  final String sharingType;
  final String occupancy; // e.g. "2/3 beds"
  final List<String> tenantImages;
  final List<BedInfo> beds;

  Room({
    required this.id,
    required this.roomNumber,
    required this.sharingType,
    required this.occupancy,
    required this.tenantImages,
    required this.beds,
  });
}

class BedInfo {
  final String bedNumber;
  final String status; // 'FREE' | 'OCCUPIED' | 'NOTICE' | 'AWAY'
  final String? tenantName;
  final String? tenantAvatar;
  final String? tenantId;

  BedInfo({
    required this.bedNumber,
    required this.status,
    this.tenantName,
    this.tenantAvatar,
    this.tenantId,
  });
}
