import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/socket/socket_service.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../core/utils/logger.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final RoomRepository roomRepository;
  final DashboardRepository dashboardRepository;
  final SocketService socketService;
  StreamSubscription? _socketSubscription;
  String? _lastHostelId;

  DashboardBloc({
    required this.roomRepository, 
    required this.dashboardRepository,
    required this.socketService,
  }) : super(const DashboardState()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<ChangeFloorFilter>(_onChangeFloorFilter);

    // Listen for real-time refresh requests from socket with a small debounce
    _socketSubscription = socketService.dashboardRefreshStream.listen((data) {
      AppLogger.info('🔄 DashboardBloc: Received refresh event from socket');
      if (_lastHostelId != null) {
        _debounceRefresh(() {
          add(FetchDashboardData(_lastHostelId!, forceRefresh: true));
        });
      } else {
        AppLogger.warning('⚠️ DashboardBloc: Received refresh but _lastHostelId is null');
      }
    });
  }

  Timer? _debounceTimer;
  void _debounceRefresh(void Function() action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), action);
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    _lastHostelId = event.hostelId;

    // Optimization: Skip fetch if data is fresh, unless forceRefresh is true (e.g. Pull-to-Refresh)
    if (!state.isStale && !event.forceRefresh) {
      return;
    }

    // Optimization: Silent Refresh. Only show loading if we don't have data yet.
    if (state.status != DashboardStatus.success) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

    try {
      final results = await Future.wait([
        roomRepository.getOccupancy(event.hostelId),
        dashboardRepository.getDailyOperations(event.hostelId),
      ]);
      emit(state.copyWith(
        status: DashboardStatus.success,
        occupancy: results[0] as dynamic,
        dailyOperations: results[1] as dynamic,
        lastFetched: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onChangeFloorFilter(
    ChangeFloorFilter event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedFloorIndex: event.floorIndex));
  }
}
