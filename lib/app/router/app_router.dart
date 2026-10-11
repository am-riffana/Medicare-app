import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../core/widgets/error_view.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/patient_home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import 'route_names.dart';

/// Helper to convert a Stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central declarative router configuration for MediCare
class AppRouter {
  AppRouter._();

  /// Factory method to create a GoRouter instance wired to AuthBloc
  static GoRouter createRouter({
    AuthBloc? authBloc,
    String initialLocation = RouteNames.splashPath,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return GoRouter(
      navigatorKey:
          navigatorKey ?? GlobalKey<NavigatorState>(debugLabel: 'root'),
      initialLocation: initialLocation,
      debugLogDiagnostics: false,
      refreshListenable:
          authBloc != null ? GoRouterRefreshStream(authBloc.stream) : null,
      redirect: (BuildContext context, GoRouterState state) {
        if (authBloc == null) return null;

        final AuthState authState = authBloc.state;
        final bool isAuthenticated = authState is Authenticated;
        final String location = state.uri.path;

        final bool isAuthRoute = location == RouteNames.loginPath ||
            location == RouteNames.registerPath ||
            location == RouteNames.forgotPasswordPath;

        // If authenticated and visiting auth routes, redirect to patient home
        if (isAuthenticated && isAuthRoute) {
          return RouteNames.patientHomePath;
        }

        // If not authenticated and attempting to view protected screens, redirect to login
        final bool isProtectedRoute =
            location == RouteNames.patientHomePath;
        if (!isAuthenticated && isProtectedRoute) {
          return RouteNames.loginPath;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splashPath,
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.onboardingPath,
          name: RouteNames.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RouteNames.loginPath,
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.registerPath,
          name: RouteNames.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: RouteNames.forgotPasswordPath,
          name: RouteNames.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RouteNames.patientHomePath,
          name: RouteNames.patientHome,
          builder: (context, state) {
            final user = authBloc?.state is Authenticated
                ? (authBloc!.state as Authenticated).user
                : null;
            return PatientHomeScreen(user: user);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: AppErrorView(
          title: 'Page Not Found',
          message: 'The requested route "${state.uri}" does not exist.',
          onRetry: () => context.goNamed(RouteNames.splash),
          retryText: 'Back to Home',
        ),
      ),
    );
  }
}
