import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.hostelId,
    required super.licenseType,
    required super.licenseNumber,
    super.expiryDate,
    required super.documentUrl,
    required super.status,
    required super.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: (json['_id'] ?? '').toString(),
      hostelId: (json['hostel'] ?? '').toString(),
      licenseType: json['licenseType']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString(),
      documentUrl: json['documentUrl']?.toString() ?? json['document']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
