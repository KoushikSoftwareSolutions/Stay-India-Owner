import '../entities/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getDocuments(String hostelId);
  Future<Document> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  });
  Future<void> deleteDocument(String id);
}
