import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC managing authentication state across MediCare
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final UserModel? user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String email = event.email.trim();
    final String password = event.password;

    if (email.isEmpty) {
      emit(const AuthFailure('Email address is required.'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthFailure('Please enter a valid email address.'));
      return;
    }

    if (password.isEmpty) {
      emit(const AuthFailure('Password is required.'));
      return;
    }

    emit(const AuthLoading());
    try {
      final UserModel user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(const AuthFailure('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String name = event.name.trim();
    final String email = event.email.trim();
    final String? phone = event.phone?.trim();
    final String password = event.password;
    final String confirmPassword = event.confirmPassword;

    if (name.isEmpty) {
      emit(const AuthFailure('Full name is required.'));
      return;
    }

    if (email.isEmpty) {
      emit(const AuthFailure('Email address is required.'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthFailure('Please enter a valid email address.'));
      return;
    }

    if (phone != null && phone.isNotEmpty && !_isValidPhone(phone)) {
      emit(const AuthFailure('Please enter a valid phone number.'));
      return;
    }

    if (password.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters.'));
      return;
    }

    if (password != confirmPassword) {
      emit(const AuthFailure('Passwords do not match.'));
      return;
    }

    emit(const AuthLoading());
    try {
      final UserModel user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      emit(Authenticated(user));
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(const AuthFailure('An unexpected error occurred during registration.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
    } catch (_) {
      // Continue to unauthenticated even if remote signOut fails
    }
    emit(const Unauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String email = event.email.trim();

    if (email.isEmpty) {
      emit(const AuthFailure('Email address is required.'));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthFailure('Please enter a valid email address.'));
      return;
    }

    emit(const AuthLoading());
    try {
      await _authRepository.resetPassword(email: email);
      emit(const PasswordResetSuccess(
        'Password reset link has been sent to your email.',
      ));
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(const AuthFailure('Failed to send reset link. Please try again.'));
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final RegExp phoneRegExp = RegExp(r'^\+?[0-9\s\-()]{7,15}$');
    return phoneRegExp.hasMatch(phone);
  }
}
