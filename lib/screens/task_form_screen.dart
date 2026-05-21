import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_messenger.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_form_widget.dart';

class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, this.taskId});

  final int? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final authState = ref.watch(authProvider);
    final existingTask = taskId == null
        ? null
        : ref.read(taskProvider.notifier).getTaskById(taskId!);
    final isEditing = existingTask != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: TaskFormWidget(
                initialTask: existingTask,
                isLoading: taskState.isSaving,
                submitLabel: isEditing ? 'Update task' : 'Create task',
                onSubmit: (value) async {
                  final baseTask =
                      existingTask ??
                      TaskModel(
                        id: 0,
                        title: '',
                        description: '',
                        priority: TaskPriority.medium,
                        dueDate: null,
                        status: TaskStatus.pending,
                        userId: authState.user?.id ?? 0,
                      );

                  final requestTask = baseTask.copyWith(
                    title: value.title,
                    description: value.description,
                    priority: value.priority,
                    dueDate: value.dueDate,
                    clearDueDate: value.dueDate == null,
                    status: value.status,
                  );

                  try {
                    if (isEditing) {
                      await ref
                          .read(taskProvider.notifier)
                          .editTask(requestTask);
                      showAppSnackBar('Task updated');
                    } else {
                      await ref
                          .read(taskProvider.notifier)
                          .addTask(requestTask);
                      showAppSnackBar('Task added');
                    }

                    if (context.mounted) {
                      context.pop();
                    }
                  } catch (error) {
                    showAppSnackBar(
                      error.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
