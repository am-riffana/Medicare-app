import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Root application widget configuring MaterialApp.router, theme, and AuthBloc
class MediCareApp extends StatefulWidget {
  final GoRouter? router;
  final AuthBloc? authBloc;

  const MediCareApp({super.key, this.router, this.authBloc});

  @override
  State<MediCareApp> createState() => _MediCareAppState();
}

class _MediCareAppState extends State<MediCareApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  bool _isLocalBloc = false;

  @override
  void initState() {
    super.initState();
    if (widget.authBloc != null) {
      _authBloc = widget.authBloc!;
    } else {
      _authBloc = AuthBloc()..add(const CheckAuthStatus());
      _isLocalBloc = true;
    }
    _router = widget.router ?? AppRouter.createRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    if (_isLocalBloc) {
      _authBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
