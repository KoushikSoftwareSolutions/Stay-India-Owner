import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardData extends DashboardEvent {
  final String hostelId;
  final bool forceRefresh;

  const FetchDashboardData(this.hostelId, {this.forceRefresh = false});

  @override
  List<Object?> get props => [hostelId, forceRefresh];
}

class ChangeFloorFilter extends DashboardEvent {
  final int floorIndex;
  const ChangeFloorFilter(this.floorIndex);

  @override
  List<Object?> get props => [floorIndex];
}
