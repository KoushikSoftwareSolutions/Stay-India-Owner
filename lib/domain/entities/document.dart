class Document {
  final String id;
  final String hostelId;
  final String licenseType;
  final String licenseNumber;
  final String? expiryDate;
  final String documentUrl;
  final String status;
  final String createdAt;

  const Document({
    required this.id,
    required this.hostelId,
    required this.licenseType,
    required this.licenseNumber,
    this.expiryDate,
    required this.documentUrl,
    required this.status,
    required this.createdAt,
  });
}
