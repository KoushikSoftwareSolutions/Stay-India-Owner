import '../entities/occupancy_summary.dart';
import '../entities/room_detail.dart';

abstract class RoomRepository {
  Future<Occupancy> getOccupancy(String hostelId);
  Future<List<FloorData>> getFloorWiseRooms(String hostelId);
  Future<List<RoomDetail>> getRooms({bool? isMaster});
  Future<List<int>> getFloors(String hostelId);
  Future<List<RoomDetail>> getRoomsByFloor(String hostelId, int floor);
  Future<List<String>> getFreeBeds(String roomId);
  Future<Map<String, dynamic>> getBedDetail(String roomId, String bedNumber);
  Future<List<Map<String, dynamic>>> getBedHistory(String roomId, String bedNumber);
  Future<RoomDetail> createRoom(RoomDetail room, String hostelId);
  Future<RoomDetail> updateRoom(RoomDetail room);
  Future<void> deleteRoom(String id);
}
