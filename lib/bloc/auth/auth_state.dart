import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final bool isActive;

  AuthSuccess({required this.token, required this.isActive});

  @override
  List<Object?> get props => [token, isActive];
}

class AuthRegisterSuccess extends AuthState {
  final Map<String, dynamic> userData;
  final String message;

  AuthRegisterSuccess({required this.userData, required this.message});

  @override
  List<Object?> get props => [userData, message];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}

class ActivationCodeSent extends AuthState {
  final String message;

  ActivationCodeSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ResetPasswordSuccess extends AuthState {
  final String message;

  ResetPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
