import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/room_detail.dart';
import '../../../domain/repositories/room_repository.dart';

// States
abstract class RoomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<RoomDetail> rooms;
  RoomLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class RoomOperationSuccess extends RoomState {
  final String message;
  RoomOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class RoomError extends RoomState {
  final String message;
  RoomError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class RoomCubit extends Cubit<RoomState> {
  final RoomRepository roomRepository;

  RoomCubit({required this.roomRepository}) : super(RoomInitial());

  Future<void> getRooms({bool? isMaster}) async {
    emit(RoomLoading());
    try {
      final rooms = await roomRepository.getRooms(isMaster: isMaster);
      emit(RoomLoaded(rooms));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> createRoom({
    required String hostelId,
    required String roomTypename,
    required int floor,
    required String sharingType,
    required String roomType,
    required double rent,
    required double deposit,
    required double maintenance,
    bool isMaster = false,
  }) async {
    try {
      final room = RoomDetail(
        id: '',
        hostelId: hostelId,
        roomTypename: roomTypename,
        floor: floor,
        sharingType: sharingType,
        roomType: roomType,
        rent: rent,
        deposit: deposit,
        maintenance: maintenance,
        isActive: true,
        isMaster: isMaster,
      );
      await roomRepository.createRoom(room, hostelId);
      emit(RoomOperationSuccess('Room created successfully'));
      await getRooms(isMaster: isMaster);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> updateRoom(RoomDetail room) async {
    try {
      await roomRepository.updateRoom(room);
      emit(RoomOperationSuccess('Room updated successfully'));
      await getRooms(isMaster: room.isMaster);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  Future<void> deleteRoom(String id, {bool? isMaster}) async {
    try {
      await roomRepository.deleteRoom(id);
      emit(RoomOperationSuccess('Room deleted successfully'));
      await getRooms(isMaster: isMaster);
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }
}
