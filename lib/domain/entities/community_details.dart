class CommunityDetails {
  final String id;
  final String hostel;
  final String name;
  final String owner;
  final int memberCount;
  final int adminCount;
  final bool isActive;
  final HostelSummary hostelDetails;

  CommunityDetails({
    required this.id,
    required this.hostel,
    required this.name,
    required this.owner,
    required this.memberCount,
    required this.adminCount,
    required this.isActive,
    required this.hostelDetails,
  });
}

class HostelSummary {
  final String id;
  final String name;
  final String city;
  final String area;
  final String coverImage;

  HostelSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.coverImage,
  });
}
