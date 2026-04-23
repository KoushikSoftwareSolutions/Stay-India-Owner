import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/hostel_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/utils/logger.dart';

abstract class HostelRemoteDataSource {
  Future<List<HostelModel>> getHostels();
  Future<HostelModel> createHostel(HostelModel hostel);
  Future<HostelModel> updateHostel(HostelModel hostel);
  Future<void> deleteHostel(String id);
  Future<HostelModel> uploadHostelImages(String id, List<String> filePaths);
}

class HostelRemoteDataSourceImpl implements HostelRemoteDataSource {
  final Dio dio;

  HostelRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HostelModel>> getHostels() async {
    try {
      final response = await dio.get(ApiConstants.hostels);
      
      if (response.statusCode == 200) {
        // Handle both direct list and { data: [...] } structure
        final dynamic data = response.data is List ? response.data : response.data['data'];
        if (data is List) {
          return data.map((json) => HostelModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch hostels');
      }
    } catch (e) {
      throw Exception('Error fetching hostels: $e');
    }
  }

  @override
  Future<HostelModel> createHostel(HostelModel hostel) async {
    try {
      final response = await dio.post(
        ApiConstants.hostels,
        data: hostel.toJson(),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      } else {
        throw Exception('Failed to create hostel');
      }
    } catch (e) {
      throw Exception('Error creating hostel: $e');
    }
  }

  @override
  Future<HostelModel> updateHostel(HostelModel hostel) async {
    try {
      final response = await dio.put(
        '${ApiConstants.hostels}/${hostel.id}',
        data: hostel.toJson(),
      );
      
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      } else {
        throw Exception('Failed to update hostel');
      }
    } catch (e) {
      throw Exception('Error updating hostel: $e');
    }
  }

  @override
  Future<void> deleteHostel(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.hostels}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete hostel');
      }
    } catch (e) {
      throw Exception('Error deleting hostel: $e');
    }
  }

  @override
  Future<HostelModel> uploadHostelImages(String id, List<String> filePaths) async {
    try {
      final formData = FormData();
      final tempDir = await getTemporaryDirectory();

      for (final path in filePaths) {
        String uploadPath = path;
        
        try {
          final File file = File(path);
          // Always use .jpg for the compressed output to satisfy the library requirements
          final String targetPath = p.join(tempDir.path, "temp_hostel_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(path)}.jpg");
          
          AppLogger.info('Compressing hostel image: $path -> $targetPath');
          
          final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            targetPath,
            quality: 50,
            minWidth: 1024,
            minHeight: 1024,
          );

          if (compressedFile != null) {
            uploadPath = compressedFile.path;
          }
        } catch (e) {
          AppLogger.error('Hostel image compression failed, using original: $e');
        }

        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            uploadPath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ));
      }

      final response = await dio.post(
        '${ApiConstants.hostels}/$id/images',
        data: formData,
        options: Options(
          headers: {'x-upload-folder': 'hostels'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return HostelModel.fromJson(data);
      }
      throw Exception('Failed to upload hostel images');
    } catch (e) {
      rethrow;
    }
  }
}
