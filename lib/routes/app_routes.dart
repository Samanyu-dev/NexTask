import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/task_details_screen.dart';
import '../screens/task_form_screen.dart';

class AppRoutes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String dashboard = 'dashboard';
  static const String addTask = 'add-task';
  static const String editTask = 'edit-task';
  static const String taskDetails = 'task-details';

  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String dashboardPath = '/dashboard';
  static const String addTaskPath = '/tasks/add';
  static const String taskDetailsPath = '/tasks/:taskId';
  static const String editTaskPath = '/tasks/:taskId/edit';

  static String taskDetailsLocation(int taskId) => '/tasks/$taskId';
  static String editTaskLocation(int taskId) => '/tasks/$taskId/edit';
}

final _routerKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  CustomTransitionPage<void> fadePage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  return GoRouter(
    navigatorKey: _routerKey,
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.loginPath || location == AppRoutes.registerPath;

      if (authState.isInitializing) {
        if (location == AppRoutes.splashPath) {
          return null;
        }
        return AppRoutes.splashPath;
      }

      if (!authState.isAuthenticated) {
        if (isAuthRoute) {
          return null;
        }
        return AppRoutes.loginPath;
      }

      if (location == AppRoutes.splashPath || isAuthRoute) {
        return AppRoutes.dashboardPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        pageBuilder: (context, state) =>
            fadePage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        pageBuilder: (context, state) =>
            fadePage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        pageBuilder: (context, state) =>
            fadePage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboard,
        pageBuilder: (context, state) =>
            fadePage(key: state.pageKey, child: const DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.addTaskPath,
        name: AppRoutes.addTask,
        pageBuilder: (context, state) =>
            fadePage(key: state.pageKey, child: const TaskFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.taskDetailsPath,
        name: AppRoutes.taskDetails,
        pageBuilder: (context, state) {
          final taskId = int.tryParse(state.pathParameters['taskId'] ?? '');
          return fadePage(
            key: state.pageKey,
            child: TaskDetailsScreen(taskId: taskId ?? 0),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editTaskPath,
        name: AppRoutes.editTask,
        pageBuilder: (context, state) {
          final taskId = int.tryParse(state.pathParameters['taskId'] ?? '');
          return fadePage(
            key: state.pageKey,
            child: TaskFormScreen(taskId: taskId),
          );
        },
      ),
    ],
  );
});
