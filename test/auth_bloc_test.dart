import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/bloc/auth/auth_bloc.dart';
import 'package:medicare/bloc/auth/auth_event.dart';
import 'package:medicare/bloc/auth/auth_state.dart';
import 'package:medicare/core/errors/failures.dart';
import 'package:medicare/data/models/user_model.dart';
import 'package:medicare/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? mockUser;
  bool shouldThrow = false;
  String errorMessage = 'Auth error';

  @override
  Future<UserModel?> checkAuthStatus() async {
    if (shouldThrow) throw AuthenticationFailure(errorMessage);
    return mockUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return checkAuthStatus();
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw AuthenticationFailure(errorMessage);
    return mockUser ??
        UserModel(
          id: 'test-user-id',
          name: 'Test Patient',
          email: email,
          role: 'patient',
        );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (shouldThrow) throw AuthenticationFailure(errorMessage);
    return mockUser ??
        UserModel(
          id: 'new-user-id',
          name: name,
          email: email,
          phone: phone,
          role: 'patient',
        );
  }

  @override
  Future<void> logout() async {
    if (shouldThrow) throw AuthenticationFailure(errorMessage);
    mockUser = null;
  }

  @override
  Future<void> resetPassword({required String email}) async {
    if (shouldThrow) throw AuthenticationFailure(errorMessage);
  }
}

void main() {
  group('AuthBloc Unit Tests', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('CheckAuthStatus', () {
      test('emits [AuthLoading, Authenticated] when session exists', () async {
        mockRepo.mockUser = const UserModel(
          id: '123',
          name: 'Sarah Connor',
          email: 'sarah@example.com',
          role: 'patient',
        );

        final expected = [
          isA<AuthLoading>(),
          isA<Authenticated>().having((s) => s.user.id, 'id', '123'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const CheckAuthStatus());
      });

      test('emits [AuthLoading, Unauthenticated] when no session exists', () async {
        mockRepo.mockUser = null;

        final expected = [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const CheckAuthStatus());
      });
    });

    group('LoginRequested', () {
      test('emits AuthFailure on empty email', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            contains('Email address is required'),
          )),
        );

        authBloc.add(const LoginRequested(email: '', password: 'password123'));
      });

      test('emits AuthFailure on invalid email format', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            contains('valid email address'),
          )),
        );

        authBloc.add(const LoginRequested(email: 'notanemail', password: 'password123'));
      });

      test('emits AuthFailure on empty password', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            contains('Password is required'),
          )),
        );

        authBloc.add(const LoginRequested(email: 'test@example.com', password: ''));
      });

      test('emits [AuthLoading, Authenticated] on valid credentials', () async {
        final expected = [
          isA<AuthLoading>(),
          isA<Authenticated>().having(
            (s) => s.user.email,
            'email',
            'test@example.com',
          ),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LoginRequested(
          email: 'test@example.com',
          password: 'secretPassword1',
        ));
      });

      test('emits [AuthLoading, AuthFailure] when credentials are wrong', () async {
        mockRepo.shouldThrow = true;
        mockRepo.errorMessage = 'Invalid email or password.';

        final expected = [
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (s) => s.message,
            'message',
            'Invalid email or password.',
          ),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LoginRequested(
          email: 'test@example.com',
          password: 'wrongPassword',
        ));
      });
    });

    group('RegisterRequested', () {
      test('emits AuthFailure on empty name', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having((s) => s.message, 'message', contains('Full name is required'))),
        );

        authBloc.add(const RegisterRequested(
          name: '',
          email: 'new@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        ));
      });

      test('emits AuthFailure when password is less than 6 chars', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having((s) => s.message, 'message', contains('at least 6 characters'))),
        );

        authBloc.add(const RegisterRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: '123',
          confirmPassword: '123',
        ));
      });

      test('emits AuthFailure when passwords do not match', () async {
        expectLater(
          authBloc.stream,
          emits(isA<AuthFailure>().having((s) => s.message, 'message', contains('Passwords do not match'))),
        );

        authBloc.add(const RegisterRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          confirmPassword: 'password456',
        ));
      });

      test('emits [AuthLoading, Authenticated] on successful registration', () async {
        final expected = [
          isA<AuthLoading>(),
          isA<Authenticated>().having((s) => s.user.name, 'name', 'John Doe'),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const RegisterRequested(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        ));
      });
    });

    group('LogoutRequested', () {
      test('emits [AuthLoading, Unauthenticated] on logout', () async {
        final expected = [
          isA<AuthLoading>(),
          isA<Unauthenticated>(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const LogoutRequested());
      });
    });

    group('ForgotPasswordRequested', () {
      test('emits [AuthLoading, PasswordResetSuccess] on valid email', () async {
        final expected = [
          isA<AuthLoading>(),
          isA<PasswordResetSuccess>(),
        ];

        expectLater(authBloc.stream, emitsInOrder(expected));
        authBloc.add(const ForgotPasswordRequested(email: 'reset@example.com'));
      });
    });
  });
}
