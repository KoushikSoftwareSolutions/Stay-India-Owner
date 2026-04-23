import 'package:equatable/equatable.dart';
import '../../../domain/entities/occupancy_summary.dart';
import '../../../domain/entities/daily_operations.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int selectedFloorIndex;
  final Occupancy? occupancy;
  final DailyOperations? dailyOperations;
  final String? errorMessage;

  final DateTime? lastFetched;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.selectedFloorIndex = 0,
    this.occupancy,
    this.dailyOperations,
    this.errorMessage,
    this.lastFetched,
  });

  bool get isStale {
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched!).inMinutes >= 30; // 30 minute stale buffer
  }

  DashboardState copyWith({
    DashboardStatus? status,
    int? selectedFloorIndex,
    Occupancy? occupancy,
    DailyOperations? dailyOperations,
    String? errorMessage,
    DateTime? lastFetched,
  }) {
    return DashboardState(
      status: status ?? this.status,
      selectedFloorIndex: selectedFloorIndex ?? this.selectedFloorIndex,
      occupancy: occupancy ?? this.occupancy,
      dailyOperations: dailyOperations ?? this.dailyOperations,
      errorMessage: errorMessage ?? this.errorMessage,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedFloorIndex,
        occupancy,
        dailyOperations,
        errorMessage,
        lastFetched,
      ];
}
