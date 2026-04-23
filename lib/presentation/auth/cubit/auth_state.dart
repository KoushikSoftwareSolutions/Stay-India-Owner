part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Unauthenticated extends AuthState {}

class ProfileCompleted extends AuthSuccess {
  const ProfileCompleted({required super.owner});
}

class AuthSuccess extends AuthState {
  final Owner owner;
  final bool isNewUser;
  const AuthSuccess({required this.owner, this.isNewUser = false});

  @override
  List<Object> get props => [owner.id, isNewUser, owner.isProfileComplete];
}

class OtpSentSuccess extends AuthState {
  final String phone;
  final bool isResend;
  final String? otp;
  const OtpSentSuccess({required this.phone, this.isResend = false, this.otp});

  @override
  List<Object> get props => [phone, isResend, if (otp != null) otp!];
}


class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthRestorationError extends AuthState {
  final String message;
  const AuthRestorationError({required this.message});

  @override
  List<Object> get props => [message];
}
