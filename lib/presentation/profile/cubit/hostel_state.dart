import '../../../domain/entities/hostel.dart';

abstract class HostelState {
  final DateTime? lastFetched;
  HostelState({this.lastFetched});

  bool get isStale {
    if (lastFetched == null) return true;
    return DateTime.now().difference(lastFetched!).inMinutes >= 5; // 5 minute buffer for hostels
  }
}

class HostelInitial extends HostelState {}

class HostelLoading extends HostelState {
  HostelLoading({super.lastFetched});
}

class HostelLoaded extends HostelState {
  final List<Hostel> hostels;
  final int selectedHostelIndex;
  
  HostelLoaded({
    required this.hostels, 
    this.selectedHostelIndex = 0,
    super.lastFetched,
  });
}

class HostelOperationSuccess extends HostelState {
  final String message;
  final String? hostelId;
  HostelOperationSuccess({required this.message, this.hostelId});
}

class HostelError extends HostelState {
  final String message;
  HostelError({required this.message});
}
