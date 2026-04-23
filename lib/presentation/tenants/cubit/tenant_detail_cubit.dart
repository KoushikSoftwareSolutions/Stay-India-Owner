import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tenant_detail.dart';
import '../../../domain/repositories/tenant_detail_repository.dart';
import '../../../../core/utils/error_helper.dart';

abstract class TenantDetailState {}

class TenantDetailInitial extends TenantDetailState {}

class TenantDetailLoading extends TenantDetailState {}

class TenantDetailLoaded extends TenantDetailState {
  final TenantDetail detail;
  TenantDetailLoaded({required this.detail});
}

class TenantDetailError extends TenantDetailState {
  final String message;
  TenantDetailError({required this.message});
}

class TenantDetailCubit extends Cubit<TenantDetailState> {
  final TenantDetailRepository tenantDetailRepository;

  TenantDetailCubit({required this.tenantDetailRepository})
      : super(TenantDetailInitial());

  Future<void> loadDetail(String tenantId, String hostelId) async {
    emit(TenantDetailLoading());
    try {
      final detail =
          await tenantDetailRepository.getTenantDetail(tenantId, hostelId);
      emit(TenantDetailLoaded(detail: detail));
    } catch (e) {
      emit(TenantDetailError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
