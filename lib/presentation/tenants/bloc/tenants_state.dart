import 'package:equatable/equatable.dart';
import '../../../domain/entities/tenant.dart';

enum TenantsStatus { initial, loading, success, failure }

class TenantsState extends Equatable {
  final TenantsStatus status;
  final List<Tenant> tenants;
  final String? errorMessage;
  final int page;
  final bool hasReachedMax;
  final bool isPaginationLoading;
  final String search;

  const TenantsState({
    this.status = TenantsStatus.initial,
    this.tenants = const [],
    this.errorMessage,
    this.page = 1,
    this.hasReachedMax = false,
    this.isPaginationLoading = false,
    this.search = '',
  });

  TenantsState copyWith({
    TenantsStatus? status,
    List<Tenant>? tenants,
    String? errorMessage,
    int? page,
    bool? hasReachedMax,
    bool? isPaginationLoading,
    String? search,
  }) {
    return TenantsState(
      status: status ?? this.status,
      tenants: tenants ?? this.tenants,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tenants,
        errorMessage,
        page,
        hasReachedMax,
        isPaginationLoading,
        search,
      ];
}
