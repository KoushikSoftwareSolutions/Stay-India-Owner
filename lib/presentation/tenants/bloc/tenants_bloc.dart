import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../../../domain/entities/tenant.dart';
import 'tenants_event.dart';
import 'tenants_state.dart';

class TenantsBloc extends Bloc<TenantsEvent, TenantsState> {
  final TenantRepository tenantRepository;
  Timer? _debounce;

  TenantsBloc({required this.tenantRepository}) : super(const TenantsState()) {
    on<FetchTenants>(_onFetchTenants);
    on<SearchTenants>(_onSearchTenants);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void _onSearchTenants(SearchTenants event, Emitter<TenantsState> emit) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      add(FetchTenants(isRefresh: true, search: event.query));
    });
    emit(state.copyWith(search: event.query));
  }

  Future<void> _onFetchTenants(
    FetchTenants event,
    Emitter<TenantsState> emit,
  ) async {
    final isRefresh = event.isRefresh || event.search != null;
    final searchQuery = event.search ?? state.search;

    if (isRefresh) {
      emit(state.copyWith(
        status: TenantsStatus.loading,
        tenants: [],
        hasReachedMax: false,
        page: 1,
        isPaginationLoading: false,
        search: searchQuery,
      ));
    } else {
      if (state.hasReachedMax || state.isPaginationLoading) return;
      emit(state.copyWith(isPaginationLoading: true));
    }

    final pageToFetch = isRefresh ? 1 : state.page;

    try {
      final tenants = await tenantRepository.getTenants(
        status: event.status,
        page: pageToFetch,
        limit: 20,
        search: searchQuery,
      );

      // Race condition guard: If search query changed during fetch, ignore results
      if (searchQuery != state.search) return;

      if (tenants.isEmpty) {
        emit(state.copyWith(
          status: TenantsStatus.success,
          hasReachedMax: true,
          page: pageToFetch,
          isPaginationLoading: false,
        ));
      } else {
        final List<Tenant> updatedTenants;
        if (isRefresh) {
          updatedTenants = tenants;
        } else {
          // Merge and deduplicate by ID
          final existingIds = state.tenants.map((t) => t.id).toSet();
          updatedTenants = List<Tenant>.from(state.tenants);
          for (var tenant in tenants) {
            if (!existingIds.contains(tenant.id)) {
              updatedTenants.add(tenant);
              existingIds.add(tenant.id);
            }
          }
        }

        emit(state.copyWith(
          status: TenantsStatus.success,
          tenants: updatedTenants,
          hasReachedMax: tenants.length < 20, // If we got less than limit, we reached max
          page: pageToFetch + 1,
          isPaginationLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TenantsStatus.failure,
        errorMessage: e.toString(),
        isPaginationLoading: false,
      ));
    }
  }
}
