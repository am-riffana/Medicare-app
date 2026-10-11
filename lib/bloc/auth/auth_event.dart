import 'package:equatable/equatable.dart';

/// Base event class for AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Checks current authentication status on startup
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Request to log in with email and password
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Request to register a new patient account
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String password;
  final String confirmPassword;

  const RegisterRequested({
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, phone, password, confirmPassword];
}

/// Request to sign out
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Request to reset password via email
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
