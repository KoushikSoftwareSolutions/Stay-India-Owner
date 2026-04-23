import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/occupancy_model.dart';
import '../models/room_detail_model.dart';

abstract class RoomRemoteDataSource {
  Future<OccupancyModel> getOccupancy(String hostelId);
  Future<List<RoomDetailModel>> getRooms({bool? isMaster});
  Future<List<int>> getFloors(String hostelId);
  Future<List<RoomDetailModel>> getRoomsByFloor(String hostelId, int floor);
  Future<List<String>> getFreeBeds(String roomId);
  Future<Map<String, dynamic>> getBedDetail(String roomId, String bedNumber);
  Future<List<Map<String, dynamic>>> getBedHistory(String roomId, String bedNumber);
  Future<RoomDetailModel> createRoom(RoomDetailModel room, String hostelId);
  Future<RoomDetailModel> updateRoom(RoomDetailModel room);
  Future<void> deleteRoom(String id);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final Dio dio;

  RoomRemoteDataSourceImpl({required this.dio});

  @override
  Future<OccupancyModel> getOccupancy(String hostelId) async {
    if (hostelId.isEmpty) {
      throw Exception('Hostel ID is required to fetch occupancy');
    }
    try {
      final response = await dio.get('${ApiConstants.roomsOccupancy}/$hostelId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final dataMap = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return OccupancyModel.fromJson(dataMap);
      } else {
        throw Exception('Failed to fetch occupancy data');
      }
    } catch (e) {
      throw Exception('Error fetching occupancy: $e');
    }
  }

  @override
  Future<List<RoomDetailModel>> getRooms({bool? isMaster}) async {
    try {
      final response = await dio.get(
        ApiConstants.rooms,
        queryParameters: isMaster != null ? {'isMaster': isMaster} : null,
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data is List
            ? response.data
            : response.data['data'];
        if (data is List) {
          return data.map((j) => RoomDetailModel.fromJson(j)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch rooms');
      }
    } catch (e) {
      throw Exception('Error fetching rooms: $e');
    }
  }

  @override
  Future<List<int>> getFloors(String hostelId) async {
    try {
      final response = await dio.get('${ApiConstants.roomsFloors}/$hostelId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is List) {
          return data.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch floors');
      }
    } catch (e) {
      throw Exception('Error fetching floors: $e');
    }
  }

  @override
  Future<List<RoomDetailModel>> getRoomsByFloor(String hostelId, int floor) async {
    try {
      final response = await dio.get(
        ApiConstants.roomsByFloor,
        queryParameters: {
          'hostelId': hostelId,
          'floor': floor,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is List) {
          return data.map((j) => RoomDetailModel.fromJson(j)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch rooms by floor');
      }
    } catch (e) {
      throw Exception('Error fetching rooms by floor: $e');
    }
  }

  @override
  Future<List<String>> getFreeBeds(String roomId) async {
    try {
      final response = await dio.get('${ApiConstants.roomBeds}/$roomId/beds');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is Map && data['beds'] is List) {
          final List beds = data['beds'];
          return beds.map((e) => e['bedNumber'].toString()).toList();
        }
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        return [];
      } else {
        throw Exception('Failed to fetch beds');
      }
    } catch (e) {
      throw Exception('Error fetching beds: $e');
    }
  }

  @override
  Future<RoomDetailModel> createRoom(RoomDetailModel room, String hostelId) async {
    try {
      final response = await dio.post(
        ApiConstants.rooms,
        data: room.toCreateJson(hostelId),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return RoomDetailModel.fromJson(data);
      } else {
        throw Exception('Failed to create room');
      }
    } catch (e) {
      throw Exception('Error creating room: $e');
    }
  }

  @override
  Future<RoomDetailModel> updateRoom(RoomDetailModel room) async {
    try {
      final response = await dio.put(
        '${ApiConstants.rooms}/${room.id}',
        data: room.toUpdateJson(),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return RoomDetailModel.fromJson(data);
      } else {
        throw Exception('Failed to update room');
      }
    } catch (e) {
      throw Exception('Error updating room: $e');
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.rooms}/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete room');
      }
    } catch (e) {
      throw Exception('Error deleting room: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getBedDetail(
      String roomId, String bedNumber) async {
    try {
      final response = await dio
          .get('${ApiConstants.roomBedDetail}/$roomId/$bedNumber');
      if (response.statusCode == 200) {
        final raw = response.data;
        return (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : raw as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch bed detail');
    } catch (e) {
      throw Exception('Error fetching bed detail: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBedHistory(
      String roomId, String bedNumber) async {
    try {
      final response = await dio
          .get('${ApiConstants.roomBedHistory}/$roomId/$bedNumber');
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> list = raw['data'] is List
            ? raw['data'] as List
            : (raw is List ? raw : []);
        return list.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to fetch bed history');
    } catch (e) {
      throw Exception('Error fetching bed history: $e');
    }
  }
}
