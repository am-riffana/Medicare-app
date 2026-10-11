import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/config/supabase_config.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Data service communicating directly with Supabase Authentication and Database.
class AuthService {
  final sb.SupabaseClient _client;

  AuthService({sb.SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Stream of Supabase authentication state changes.
  Stream<sb.AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Returns currently authenticated Supabase Auth user.
  sb.User? get currentAuthUser => _client.auth.currentUser;

  /// Returns active Supabase session if available.
  sb.Session? get currentSession => _client.auth.currentSession;

  // ============================================================
  // REGISTER
  // ============================================================

  /// Registers a new user with Supabase Auth
  /// and creates their profile in public.users.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final sb.AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          'phone': phone?.trim(),
        },
      );

      final sb.User? authUser = response.user;

      if (authUser == null) {
        throw const AuthException(
          'Registration failed. Please try again.',
        );
      }

      final UserModel newUser = UserModel(
        id: authUser.id,
        name: name.trim(),
        email: email.trim(),
        phone: phone?.trim().isEmpty == true
            ? null
            : phone?.trim(),
        role: 'patient',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save profile only when a session is active.
      if (response.session != null) {
        try {
          await _client
              .from('users')
              .upsert(newUser.toJson());
        } on sb.PostgrestException catch (e) {
          debugPrint(
            '[AuthService] Profile insert warning: ${e.message}',
          );
        }
      }

      return newUser;
    } on sb.AuthException catch (e) {
      throw AuthException(
        _mapAuthErrorMessage(e.message),
        code: e.statusCode,
      );
    } on SocketException {
      throw const NetworkException(
        'Unable to connect. Please check your internet connection.',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      throw const AuthException(
        'An unexpected error occurred during registration. '
        'Please try again.',
      );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  /// Logs in using email and password,
  /// then fetches the user's profile from public.users.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('========== LOGIN START ==========');
      debugPrint('Email: ${email.trim()}');

      final sb.AuthResponse response =
          await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final sb.User? authUser = response.user;

      // Debug information to confirm Supabase login.
      debugPrint('========== LOGIN DEBUG ==========');
      debugPrint('LOGIN SUCCESS');
      debugPrint('Auth User ID: ${authUser?.id}');
      debugPrint('Auth User Email: ${authUser?.email}');
      debugPrint(
        'Session exists: ${response.session != null}',
      );
      debugPrint('=================================');

      if (authUser == null) {
        throw const AuthException(
          'Login failed. No user found.',
        );
      }

      // Fetch profile from public.users.
      debugPrint(
        '[AuthService] Fetching profile for: ${authUser.id}',
      );

      final UserModel? profile =
          await getUserProfile(authUser.id);

      debugPrint(
        '[AuthService] Profile found: ${profile != null}',
      );

      final UserModel user = profile ??
          UserModel(
            id: authUser.id,
            name:
                (authUser.userMetadata?['name'] as String?) ?? '',
            email: authUser.email ?? email.trim(),
            phone:
                authUser.userMetadata?['phone'] as String?,
            role: 'patient',
          );

      debugPrint(
        '[AuthService] User role: ${user.role}',
      );

      // Check whether the account is blocked.
      if (user.isBlocked) {
        await logout();

        throw const AuthException(
          'This account has been deactivated. '
          'Please contact support.',
        );
      }

      debugPrint('========== LOGIN COMPLETE ==========');
      debugPrint('User ID: ${user.id}');
      debugPrint('User Name: ${user.name}');
      debugPrint('User Role: ${user.role}');
      debugPrint('====================================');

      return user;
    } on sb.AuthException catch (e) {
      debugPrint(
        '[AuthService] Supabase Auth Error: ${e.message}',
      );

      throw AuthException(
        _mapAuthErrorMessage(e.message),
        code: e.statusCode,
      );
    } on SocketException {
      debugPrint(
        '[AuthService] Network error during login.',
      );

      throw const NetworkException(
        'Unable to connect. Please check your internet connection.',
      );
    } catch (e) {
      debugPrint(
        '[AuthService] Unexpected login error: $e',
      );

      if (e is AppException) {
        rethrow;
      }

      throw const AuthException(
        'An unexpected error occurred during login. '
        'Please try again.',
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  /// Logs out the current user and clears the Supabase session.
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(
        e.message,
        code: e.statusCode,
      );
    } catch (e) {
      throw const AuthException(
        'Failed to sign out. Please try again.',
      );
    }
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  /// Retrieves the user profile from public.users.
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      debugPrint(
        '[AuthService] Querying users table for ID: $userId',
      );

      final Map<String, dynamic>? data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        debugPrint(
          '[AuthService] No profile found in users table.',
        );
        return null;
      }

      debugPrint(
        '[AuthService] Profile successfully fetched.',
      );

      return UserModel.fromJson(data);
    } on sb.PostgrestException catch (e) {
      debugPrint(
        '[AuthService] getUserProfile error: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint(
        '[AuthService] Unexpected profile error: $e',
      );
      return null;
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  /// Sends password reset email.
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
      );
    } on sb.AuthException catch (e) {
      throw AuthException(
        _mapAuthErrorMessage(e.message),
        code: e.statusCode,
      );
    } on SocketException {
      throw const NetworkException(
        'Unable to connect. Please check your internet connection.',
      );
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }

      throw const AuthException(
        'Failed to send password reset email. '
        'Please try again.',
      );
    }
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  /// Checks whether there is an active Supabase session
  /// and returns the current UserModel.
  Future<UserModel?> getCurrentUser() async {
    final sb.User? authUser = currentAuthUser;

    if (authUser == null) {
      debugPrint(
        '[AuthService] No authenticated user found.',
      );
      return null;
    }

    debugPrint(
      '[AuthService] Current Auth User: ${authUser.id}',
    );

    final UserModel? profile =
        await getUserProfile(authUser.id);

    return profile ??
        UserModel(
          id: authUser.id,
          name:
              (authUser.userMetadata?['name'] as String?) ?? '',
          email: authUser.email ?? '',
          phone:
              authUser.userMetadata?['phone'] as String?,
          role: 'patient',
        );
  }

  // ============================================================
  // ERROR MAPPING
  // ============================================================

  /// Maps raw Supabase authentication errors
  /// to user-friendly messages.
  String _mapAuthErrorMessage(String rawMessage) {
    final String lower = rawMessage.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials')) {
      return 'Invalid email or password. '
          'Please verify your credentials.';
    }

    if (lower.contains('user already registered') ||
        lower.contains('already registered') ||
        lower.contains('email already in use')) {
      return 'An account with this email address already exists. '
          'Please sign in instead.';
    }

    if (lower.contains('password should be at least') ||
        lower.contains('weak password')) {
      return 'Password is too weak. '
          'Please use at least 6 characters.';
    }

    if (lower.contains('rate limit') ||
        lower.contains('too many requests')) {
      return 'Too many attempts. '
          'Please wait a few moments and try again.';
    }

    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address '
          'before signing in.';
    }

    return rawMessage;
  }
}