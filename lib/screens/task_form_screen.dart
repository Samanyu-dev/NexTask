import 'package:flutter/material.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_form_widget.dart';

class TaskFormScreen extends StatelessWidget {
  const TaskFormScreen({super.key, required this.taskProvider, this.task});

  final TaskProvider taskProvider;
  final TaskItem? task;

  @override
  Widget build(BuildContext context) {
    final isEditing = task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: TaskFormWidget(
                initialTask: task,
                submitLabel: isEditing ? 'Update task' : 'Create task',
                onSubmit: (value) {
                  final taskItem =
                      (task ??
                              TaskItem(
                                id: taskProvider.nextId(),
                                title: '',
                                description: '',
                                priority: TaskPriority.medium,
                                dueDate: null,
                                status: TaskStatus.pending,
                                userId: 1,
                              ))
                          .copyWith(
                            title: value.title,
                            description: value.description,
                            priority: value.priority,
                            status: value.status,
                            dueDate: value.dueDate,
                            clearDueDate: value.dueDate == null,
                          );

                  if (isEditing) {
                    taskProvider.updateTask(taskItem);
                  } else {
                    taskProvider.addTask(taskItem);
                  }

                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
