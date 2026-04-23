import 'package:equatable/equatable.dart';

abstract class TenantsEvent extends Equatable {
  const TenantsEvent();
  @override
  List<Object?> get props => [];
}

class FetchTenants extends TenantsEvent {
  final String status;
  final int page;
  final int limit;
  final bool isRefresh;
  final String? search;

  const FetchTenants({
    this.status = 'CHECKED_IN',
    this.page = 1,
    this.limit = 20,
    this.isRefresh = false,
    this.search,
  });

  @override
  List<Object?> get props => [status, page, limit, isRefresh, search];
}

class SearchTenants extends TenantsEvent {
  final String query;
  const SearchTenants(this.query);

  @override
  List<Object?> get props => [query];
}
