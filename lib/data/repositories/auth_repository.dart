import '../../core/errors/exceptions.dart' as exc;
import '../../core/errors/failures.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository abstraction separating AuthService from BLoC layer
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Logs in a user with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.login(email: email, password: password);
    } on exc.AuthException catch (e) {
      throw AuthenticationFailure(e.message, code: e.code);
    } on exc.NetworkException catch (e) {
      throw NetworkFailure(e.message, code: e.code);
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } catch (e) {
      throw AuthenticationFailure(e.toString());
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      return await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
    } on exc.AuthException catch (e) {
      throw AuthenticationFailure(e.message, code: e.code);
    } on exc.NetworkException catch (e) {
      throw NetworkFailure(e.message, code: e.code);
    } on exc.ServerException catch (e) {
      throw ServerFailure(e.message, code: e.code);
    } catch (e) {
      throw AuthenticationFailure(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on exc.AuthException catch (e) {
      throw AuthenticationFailure(e.message, code: e.code);
    } catch (e) {
      throw AuthenticationFailure(e.toString());
    }
  }

  Future<UserModel?> checkAuthStatus() async {
    try {
      return await _authService.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _authService.resetPassword(email: email);
    } on exc.AuthException catch (e) {
      throw AuthenticationFailure(e.message, code: e.code);
    } on exc.NetworkException catch (e) {
      throw NetworkFailure(e.message, code: e.code);
    } catch (e) {
      throw AuthenticationFailure(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    return checkAuthStatus();
  }
}
