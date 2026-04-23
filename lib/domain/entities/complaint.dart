class Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String createdAt;
  final String? tenantName;
  final String? roomTypename;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.tenantName,
    this.roomTypename,
  });
}
