import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_messenger.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ProviderScope(child: NexTaskApp()));
}

class NexTaskApp extends ConsumerWidget {
  const NexTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'NexTask',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: NexTaskTheme.light,
      routerConfig: router,
    );
  }
}
