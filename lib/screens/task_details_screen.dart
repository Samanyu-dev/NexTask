import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/app_messenger.dart';
import '../providers/task_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/loading_widget.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final task = ref.read(taskProvider.notifier).getTaskById(taskId);
    final theme = Theme.of(context);

    if (task == null && !taskState.initialized) {
      return const Scaffold(
        body: LoadingWidget(label: 'Loading task details...'),
      );
    }

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(
              AppRoutes.editTask,
              pathParameters: {'taskId': '$taskId'},
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: taskState.isSaving
                ? null
                : () async {
                    try {
                      await ref.read(taskProvider.notifier).deleteTask(task.id);
                      showAppSnackBar('Task deleted');
                      if (context.mounted) {
                        context.pop();
                      }
                    } catch (error) {
                      showAppSnackBar(
                        error.toString().replaceFirst('Exception: ', ''),
                      );
                    }
                  },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: theme.textTheme.displayMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(
                        label: task.priorityLabel,
                        color: task.priorityColor,
                      ),
                      _InfoChip(
                        label: task.statusLabel,
                        color: task.statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Description',
                    child: Text(
                      task.description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Due date',
                    child: Text(
                      task.dueDate == null
                          ? 'No due date set'
                          : DateFormat('dd MMM yyyy').format(task.dueDate!),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Priority and status',
                    child: Text(
                      '${task.priorityLabel} priority · ${task.statusLabel}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pushNamed(
                            AppRoutes.editTask,
                            pathParameters: {'taskId': '$taskId'},
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFC44536),
                          ),
                          onPressed: taskState.isSaving
                              ? null
                              : () async {
                                  try {
                                    await ref
                                        .read(taskProvider.notifier)
                                        .deleteTask(task.id);
                                    showAppSnackBar('Task deleted');
                                    if (context.mounted) {
                                      context.pop();
                                    }
                                  } catch (error) {
                                    showAppSnackBar(
                                      error.toString().replaceFirst(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
