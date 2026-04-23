import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../../domain/entities/owner.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/services/token_storage.dart';
import '../../../data/models/owner_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/error_helper.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  AuthCubit({required this.authRepository, required this.tokenStorage})
      : super(AuthInitial());

  Future<void> requestOtp(String phone) async {
    emit(AuthLoading());
    try {
      // Diagnostic log
      AppLogger.info('--- AUTH DEBUG ---');
      AppLogger.info('Effective Base URL: ${ApiConstants.baseUrl}');
      AppLogger.info('Target: ${ApiConstants.requestOtp}');
      AppLogger.info('------------------');

      final otp = await authRepository.requestOtp(phone);
      if (otp != null) {
        emit(OtpSentSuccess(phone: phone, otp: otp));
      } else {
        emit(const AuthError(message: 'Failed to send OTP'));
      }

    } catch (e) {
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> resendOtp(String phone) async {
    emit(AuthLoading());
    try {
      final otp = await authRepository.requestOtp(phone);
      if (otp != null) {
        emit(OtpSentSuccess(phone: phone, isResend: true, otp: otp));
      } else {
        emit(const AuthError(message: 'Failed to resend OTP'));
      }
    } catch (e) {
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOtp(phone, otp);
      if (response['success'] == true) {
        final isNewUser = response['isNewUser'] == true;
        final verifiedPhone = response['phone'] as String? ?? phone;
        final userJson = response['user'] as Map<String, dynamic>?;

        Owner owner;
        if (userJson != null) {
          // Build owner directly from verify-OTP response — most reliable source
          owner = OwnerModel.fromJson(userJson);
          // Patch phone if missing
          if (owner.phone.isEmpty) {
            owner = Owner(
              id: owner.id,
              name: owner.name,
              phone: verifiedPhone,
              email: owner.email,
              isProfileComplete: owner.isProfileComplete,
            );
          }
        } else {
          // Fallback: fetch from /me endpoint
          owner = await authRepository.getMe();
          if (owner.phone.isEmpty) {
            owner = Owner(
              id: owner.id,
              name: owner.name,
              phone: verifiedPhone,
              email: owner.email,
              isProfileComplete: owner.isProfileComplete,
            );
          }
        }

        // isNewUser=false + isProfileComplete=true → go straight to MainNavigationPage
        emit(AuthSuccess(owner: owner, isNewUser: isNewUser));
      } else {
        emit(AuthError(message: response['message'] ?? 'Invalid OTP'));
      }
    } catch (e) {
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }


  /// Called on app start to restore session if a token is already stored
  Future<void> loadCurrentUser() async {
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) {
      emit(Unauthenticated());
      return;
    }

    emit(AuthLoading());
    try {
      final owner = await authRepository.getMe();
      emit(AuthSuccess(owner: owner));
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        // Token expired or invalid — only clear it on explicit auth failure
        await tokenStorage.deleteToken();
        emit(Unauthenticated());
      } else {
        // Network error, 500, etc — don't logout, just show error
        emit(AuthRestorationError(message: 'Connection error: ${e.message}'));
      }
    } catch (e) {
      // For any other unexpected errors, don't automatically delete token
      emit(AuthRestorationError(message: 'Failed to restore session: $e'));
    }
  }

  Future<void> completeProfile(Map<String, dynamic> data) async {
    emit(AuthLoading());
    try {
      final success = await authRepository.completeProfile(data);
      if (success) {
        // Refresh the user data immediately to update the UI with name/avatar
        final owner = await authRepository.getMe();
        emit(ProfileCompleted(owner: owner));
      } else {
        emit(const AuthError(message: 'Failed to complete profile'));
      }
    } catch (e) {
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  /// Deletes stored token then clears auth state.
  /// Self-contained so callers don't need to manually deleteToken().
  Future<void> logout() async {
    try {
      await tokenStorage.deleteToken();
    } catch (_) {
      // Even if delete fails, we still clear local state
    } finally {
      emit(Unauthenticated());
    }
  }

  Future<String?> getToken() => tokenStorage.getToken();
}
