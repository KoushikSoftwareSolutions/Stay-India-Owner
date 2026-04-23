import '../../domain/entities/occupancy_summary.dart';
import '../../domain/entities/room_detail.dart';
import '../../domain/repositories/room_repository.dart';
import '../data_sources/room_remote_data_source.dart';
import '../models/room_detail_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Occupancy> getOccupancy(String hostelId) async {
    return await remoteDataSource.getOccupancy(hostelId);
  }

  @override
  Future<List<FloorData>> getFloorWiseRooms(String hostelId) async {
    final occupancy = await remoteDataSource.getOccupancy(hostelId);
    return occupancy.floors;
  }

  @override
  Future<List<RoomDetail>> getRooms({bool? isMaster}) async {
    return await remoteDataSource.getRooms(isMaster: isMaster);
  }

  @override
  Future<RoomDetail> createRoom(RoomDetail room, String hostelId) async {
    final model = RoomDetailModel(
      id: room.id,
      hostelId: hostelId,
      roomTypename: room.roomTypename,
      floor: room.floor,
      sharingType: room.sharingType,
      roomType: room.roomType,
      rent: room.rent,
      deposit: room.deposit,
      maintenance: room.maintenance,
      isActive: room.isActive,
      isMaster: room.isMaster,
      beds: room.beds,
    );
    return await remoteDataSource.createRoom(model, hostelId);
  }

  @override
  Future<RoomDetail> updateRoom(RoomDetail room) async {
    final model = RoomDetailModel(
      id: room.id,
      hostelId: room.hostelId,
      roomTypename: room.roomTypename,
      floor: room.floor,
      sharingType: room.sharingType,
      roomType: room.roomType,
      rent: room.rent,
      deposit: room.deposit,
      maintenance: room.maintenance,
      isActive: room.isActive,
      isMaster: room.isMaster,
      beds: room.beds,
    );
    return await remoteDataSource.updateRoom(model);
  }

  @override
  Future<List<int>> getFloors(String hostelId) async {
    return await remoteDataSource.getFloors(hostelId);
  }

  @override
  Future<List<RoomDetail>> getRoomsByFloor(String hostelId, int floor) async {
    return await remoteDataSource.getRoomsByFloor(hostelId, floor);
  }

  @override
  Future<List<String>> getFreeBeds(String roomId) async {
    return await remoteDataSource.getFreeBeds(roomId);
  }

  @override
  Future<void> deleteRoom(String id) async {
    return await remoteDataSource.deleteRoom(id);
  }

  @override
  Future<Map<String, dynamic>> getBedDetail(
      String roomId, String bedNumber) async {
    return await remoteDataSource.getBedDetail(roomId, bedNumber);
  }

  @override
  Future<List<Map<String, dynamic>>> getBedHistory(
      String roomId, String bedNumber) async {
    return await remoteDataSource.getBedHistory(roomId, bedNumber);
  }
}
