// auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LogoutRequested extends AuthEvent {}

class LoginWithGoogleRequested extends AuthEvent {}

class TokenExpiredEvent extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class CheckUserActive extends AuthEvent {
  final Map<String, dynamic> account;

  CheckUserActive({required this.account});

  @override
  List<Object?> get props => [account];
}

class SendActivationCodeRequested extends AuthEvent {}

class VerifyActivationCodeRequested extends AuthEvent {
  final String code;

  VerifyActivationCodeRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

class AppStarted extends AuthEvent {
  final bool isTokenExpired;

  AppStarted({this.isTokenExpired = false});

  @override
  List<Object?> get props => [isTokenExpired];
}
