import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/task.dart';

class TaskService {
  TaskService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TaskItem>> fetchTasks(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(TaskItem.fromJson)
              .toList();
        }
      }
    } catch (_) {
      // Fall back to local demo data when backend task APIs are not ready yet.
    }

    return demoTasks;
  }

  List<TaskItem> get demoTasks => [
    TaskItem(
      id: 1,
      title: 'Finalize onboarding plan',
      description: 'Prepare the week-one checklist for new hires.',
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: TaskStatus.inProgress,
      userId: 1,
    ),
    TaskItem(
      id: 2,
      title: 'Design sprint review deck',
      description: 'Summarize wins, blockers, and action items.',
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: TaskStatus.pending,
      userId: 1,
    ),
    TaskItem(
      id: 3,
      title: 'Follow up with vendor',
      description: 'Confirm revised timeline for delivery and support.',
      priority: TaskPriority.low,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: TaskStatus.completed,
      userId: 1,
    ),
  ];
}
