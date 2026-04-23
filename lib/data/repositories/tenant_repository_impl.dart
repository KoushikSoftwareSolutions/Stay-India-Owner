import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../data_sources/tenant_remote_data_source.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;

  TenantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Tenant>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 20,
    String? search,
  }) {
    return remoteDataSource.getTenants(
      status: status,
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  }) {
    return remoteDataSource.addManualTenant(
      phone: phone,
      hostelId: hostelId,
      roomId: roomId,
      bedNumber: bedNumber,
      rent: rent,
      firstName: firstName,
      lastName: lastName,
      sharingType: sharingType,
      startDate: startDate,
      deposit: deposit,
    );
  }
}
