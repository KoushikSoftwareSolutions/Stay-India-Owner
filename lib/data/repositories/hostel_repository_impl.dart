import '../../domain/entities/hostel.dart';
import '../../domain/repositories/hostel_repository.dart';
import '../data_sources/hostel_remote_data_source.dart';
import '../models/hostel_model.dart';

class HostelRepositoryImpl implements HostelRepository {
  final HostelRemoteDataSource remoteDataSource;

  HostelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Hostel>> getHostels() async {
    return await remoteDataSource.getHostels();
  }

  @override
  Future<Hostel> createHostel(Hostel hostel) async {
    final model = HostelModel(
      id: hostel.id,
      name: hostel.name,
      address: hostel.address,
      floors: hostel.floors,
      hostelType: hostel.hostelType,
      city: hostel.city,
      state: hostel.state,
      area: hostel.area,
      images: hostel.images,
      coverImage: hostel.coverImage,
      contactNumber: hostel.contactNumber,
      description: hostel.description,
      lat: hostel.lat,
      lng: hostel.lng,
    );
    return await remoteDataSource.createHostel(model);
  }

  @override
  Future<Hostel> updateHostel(Hostel hostel) async {
    final model = HostelModel(
      id: hostel.id,
      name: hostel.name,
      address: hostel.address,
      floors: hostel.floors,
      hostelType: hostel.hostelType,
      city: hostel.city,
      state: hostel.state,
      area: hostel.area,
      images: hostel.images,
      coverImage: hostel.coverImage,
      contactNumber: hostel.contactNumber,
      description: hostel.description,
      lat: hostel.lat,
      lng: hostel.lng,
    );
    return await remoteDataSource.updateHostel(model);
  }

  @override
  Future<void> deleteHostel(String id) async {
    return await remoteDataSource.deleteHostel(id);
  }

  @override
  Future<Hostel> uploadHostelImages(String id, List<String> filePaths) async {
    return await remoteDataSource.uploadHostelImages(id, filePaths);
  }
}
