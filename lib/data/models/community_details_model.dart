import '../../domain/entities/community_details.dart';

class CommunityDetailsModel extends CommunityDetails {
  CommunityDetailsModel({
    required super.id,
    required super.hostel,
    required super.name,
    required super.owner,
    required super.memberCount,
    required super.adminCount,
    required super.isActive,
    required super.hostelDetails,
  });

  factory CommunityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailsModel(
      id: json['_id']?.toString() ?? '',
      hostel: json['hostel']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      memberCount: json['memberCount'] ?? 0,
      adminCount: json['adminCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      hostelDetails: HostelSummaryModel.fromJson(json['hostelDetails'] ?? {}),
    );
  }
}

class HostelSummaryModel extends HostelSummary {
  HostelSummaryModel({
    required super.id,
    required super.name,
    required super.city,
    required super.area,
    required super.coverImage,
  });

  factory HostelSummaryModel.fromJson(Map<String, dynamic> json) {
    return HostelSummaryModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      coverImage: json['coverImage']?.toString() ?? '',
    );
  }
}
