import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';

void main() {
  runApp(const NexTaskApp());
}

class NexTaskApp extends StatefulWidget {
  const NexTaskApp({super.key, this.authProvider, this.taskProvider});

  final AuthProvider? authProvider;
  final TaskProvider? taskProvider;

  @override
  State<NexTaskApp> createState() => _NexTaskAppState();
}

class _NexTaskAppState extends State<NexTaskApp> {
  late final AuthProvider _authProvider;
  late final TaskProvider _taskProvider;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _authProvider = widget.authProvider ?? AuthProvider(AuthService());
    _taskProvider = widget.taskProvider ?? TaskProvider(TaskService());
    _authProvider.initialize();
  }

  @override
  void dispose() {
    if (widget.authProvider == null) {
      _authProvider.dispose();
    }
    if (widget.taskProvider == null) {
      _taskProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_authProvider, _taskProvider]),
      builder: (context, _) {
        return MaterialApp(
          title: 'NexTask',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_authProvider.initializing) {
      return const SplashScreen();
    }

    if (_authProvider.isAuthenticated) {
      return DashboardScreen(
        authProvider: _authProvider,
        taskProvider: _taskProvider,
      );
    }

    if (_showRegister) {
      return RegisterScreen(
        authProvider: _authProvider,
        onLoginTap: () {
          setState(() => _showRegister = false);
        },
      );
    }

    return LoginScreen(
      authProvider: _authProvider,
      onRegisterTap: () {
        setState(() => _showRegister = true);
      },
    );
  }
}
