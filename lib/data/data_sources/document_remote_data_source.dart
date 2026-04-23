import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/document_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/utils/logger.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments(String hostelId);
  Future<DocumentModel> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  });
  Future<void> deleteDocument(String id);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final Dio dio;

  DocumentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<DocumentModel>> getDocuments(String hostelId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.documentsHostel}/$hostelId',
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        final data = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ??
            (raw['data'] is List ? raw['data'] as List : []);
        return items
            .map((d) => DocumentModel.fromJson(d as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load documents');
    } catch (e) {
      throw Exception('Error loading documents: $e');
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String hostelId,
    required String licenseType,
    required String licenseNumber,
    String? expiryDate,
    required String filePath,
  }) async {
    try {
      String uploadPath = filePath;
      
      // Compress if it's an image
      final String ext = p.extension(filePath).toLowerCase();
      if (['.jpg', '.jpeg', '.png', '.heic', '.heif', '.webp'].contains(ext)) {
        try {
          final tempDir = await getTemporaryDirectory();
          final targetPath = p.join(tempDir.path, "temp_doc_${DateTime.now().millisecondsSinceEpoch}.jpg");
          
          AppLogger.info('Compressing document image: $filePath -> $targetPath');
          
          final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
            filePath,
            targetPath,
            quality: 50,
            minWidth: 1024,
            minHeight: 1024,
          );

          if (compressedFile != null) {
            uploadPath = compressedFile.path;
          }
        } catch (e) {
          AppLogger.error('Document compression failed: $e');
        }
      }

      final formData = FormData.fromMap({
        'hostel': hostelId,
        'licenseType': licenseType,
        'licenseNumber': licenseNumber,
        if (expiryDate != null) 'expiryDate': expiryDate,
      });
      formData.files.add(MapEntry(
        'document',
        await MultipartFile.fromFile(
          uploadPath,
          contentType: DioMediaType('image', 'jpeg'),
        ),
      ));
      
      final response = await dio.post(
        ApiConstants.documents,
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return DocumentModel.fromJson(data);
      }
      throw Exception('Failed to upload document');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.documents}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }
}
