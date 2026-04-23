import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/hostel.dart';
import '../../../domain/repositories/hostel_repository.dart';
import 'hostel_state.dart';

class HostelCubit extends Cubit<HostelState> {
  final HostelRepository hostelRepository;

  HostelCubit({required this.hostelRepository}) : super(HostelInitial());

  Future<void> getHostels({bool forceRefresh = false}) async {
    // Optimization: Skip fetch if data is fresh, unless forceRefresh is true
    if (!state.isStale && !forceRefresh && state is HostelLoaded) {
      return;
    }

    final int currentIndex = state is HostelLoaded ? (state as HostelLoaded).selectedHostelIndex : 0;
    
    // Optimization: Silent Refresh. Only show loading if we don't have data yet.
    if (state is! HostelLoaded) {
      emit(HostelLoading(lastFetched: state.lastFetched));
    }
    
    try {
      final hostels = await hostelRepository.getHostels();
      emit(HostelLoaded(
        hostels: hostels,
        selectedHostelIndex: currentIndex < hostels.length ? currentIndex : 0,
        lastFetched: DateTime.now(),
      ));
    } catch (e) {
      emit(HostelError(message: e.toString()));
    }
  }

  void selectHostel(int index) {
    if (state is HostelLoaded) {
      final loadedState = state as HostelLoaded;
      if (index >= 0 && index < loadedState.hostels.length) {
        emit(HostelLoaded(
          hostels: loadedState.hostels,
          selectedHostelIndex: index,
        ));
      }
    }
  }

  Future<void> createHostel({
    required String name,
    required String address,
    required int floors,
    required String hostelType,
    required String city,
    required String state,
    String area = '',
    String contactNumber = '',
    String description = '',
    String propertyTag = 'PG',
    double? lat,
    double? lng,
  }) async {
    emit(HostelLoading());
    try {
      final hostel = Hostel(
        id: '',
        name: name,
        address: address,
        floors: floors,
        hostelType: hostelType,
        city: city,
        state: state,
        area: area,
        contactNumber: contactNumber,
        description: description,
        propertyTag: propertyTag,
        lat: lat,
        lng: lng,
      );
      final createdHostel = await hostelRepository.createHostel(hostel);
      emit(HostelOperationSuccess(
        message: 'Hostel created successfully',
        hostelId: createdHostel.id,
      ));
      await getHostels(); // Refresh list
    } catch (e) {
      emit(HostelError(message: e.toString()));
    }
  }

  Future<void> uploadHostelImages({
    required String id,
    required List<String> filePaths,
  }) async {
    emit(HostelLoading());
    try {
      await hostelRepository.uploadHostelImages(id, filePaths);
      emit(HostelOperationSuccess(message: 'Images uploaded successfully'));
      await getHostels(); // Refresh list to get updated images
    } catch (e) {
      emit(HostelError(message: e.toString()));
    }
  }

  Future<void> deleteHostel(String id) async {
    emit(HostelLoading());
    try {
      await hostelRepository.deleteHostel(id);
      emit(HostelOperationSuccess(message: 'Hostel deleted successfully'));
      await getHostels(); // Refresh list
    } catch (e) {
      emit(HostelError(message: e.toString()));
    }
  }
}
