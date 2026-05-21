import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_messenger.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/loading_widget.dart';
import '../widgets/task_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskState = ref.read(taskProvider);
      if (!taskState.initialized) {
        ref.read(taskProvider.notifier).fetchTasks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final taskState = ref.watch(taskProvider);
    final theme = Theme.of(context);
    final visibleTasks = taskState.visibleTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authState.isLoading ? null : _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.addTask),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F3EC), Color(0xFFF0F6F2), Color(0xFFFDF9F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => ref.read(taskProvider.notifier).fetchTasks(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              _HeroSummary(
                name: authState.user?.name ?? 'Team',
                total: taskState.tasks.length,
                pending: taskState.tasks
                    .where((task) => task.status == TaskStatus.pending)
                    .length,
                completed: taskState.tasks
                    .where((task) => task.status == TaskStatus.completed)
                    .length,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: ref.read(taskProvider.notifier).setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search tasks, descriptions, or priorities',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<TaskStatus?>(
                initialValue: taskState.statusFilter,
                decoration: const InputDecoration(
                  labelText: 'Filter by status',
                ),
                items: const [
                  DropdownMenuItem<TaskStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.pending,
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.inProgress,
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.completed,
                    child: Text('Completed'),
                  ),
                ],
                onChanged: ref.read(taskProvider.notifier).setStatusFilter,
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildBody(
                  theme: theme,
                  taskState: taskState,
                  visibleTasks: visibleTasks,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required ThemeData theme,
    required TaskState taskState,
    required List<TaskModel> visibleTasks,
  }) {
    if (taskState.isLoading && !taskState.initialized) {
      return const SizedBox(
        key: ValueKey('loading'),
        height: 260,
        child: LoadingWidget(label: 'Fetching your tasks...'),
      );
    }

    if (taskState.errorMessage != null && taskState.tasks.isEmpty) {
      return Card(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 40),
              const SizedBox(height: 12),
              Text('Unable to load tasks', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                taskState.errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (visibleTasks.isEmpty) {
      return Card(
        key: const ValueKey('empty'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.inbox_rounded, size: 42),
              const SizedBox(height: 12),
              Text('No tasks found', style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Try a new search, clear the filter, or create your next priority task.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      key: const ValueKey('content'),
      children: [
        for (final task in visibleTasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TaskCard(
              task: task,
              onTap: () => context.pushNamed(
                AppRoutes.taskDetails,
                pathParameters: {'taskId': '${task.id}'},
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    showAppSnackBar('Logged out');
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.name,
    required this.total,
    required this.pending,
    required this.completed,
  });

  final String name;
  final int total;
  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF123C35), Color(0xFF2E6C59), Color(0xFFE08A1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123C35).withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good to see you, $name',
            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the urgent work visible, the noisy work filtered, and the day under control.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(label: 'Total', value: '$total'),
              _StatPill(label: 'Pending', value: '$pending'),
              _StatPill(label: 'Completed', value: '$completed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(' ', style: TextStyle(fontSize: 0)),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
