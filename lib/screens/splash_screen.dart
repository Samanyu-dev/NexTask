import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F3EC), Color(0xFFE5F1EC), Color(0xFFFDF8F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.track_changes_rounded, size: 44),
              ),
              const SizedBox(height: 18),
              Text('NexTask', style: theme.textTheme.displayMedium),
              const SizedBox(height: 10),
              Text(
                'Loading your workspace...',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
