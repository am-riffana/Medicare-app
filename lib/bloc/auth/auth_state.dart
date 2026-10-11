import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

/// Base state class for AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State emitted while authenticating or communicating with backend
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State emitted when a user is successfully authenticated
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State emitted when there is no authenticated session
class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// State emitted on authentication or validation failure
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// State emitted when password reset link was dispatched
class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
