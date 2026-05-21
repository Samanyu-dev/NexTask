import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, inProgress, completed }

class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
    required this.userId,
  });

  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final TaskStatus status;
  final int userId;

  String get priorityLabel => switch (priority) {
    TaskPriority.high => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low => 'Low',
  };

  String get statusLabel => switch (status) {
    TaskStatus.pending => 'Pending',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.completed => 'Completed',
  };

  Color get priorityColor => switch (priority) {
    TaskPriority.high => const Color(0xFFC44536),
    TaskPriority.medium => const Color(0xFFE08A1E),
    TaskPriority.low => const Color(0xFF2E8B57),
  };

  Color get statusColor => switch (status) {
    TaskStatus.pending => const Color(0xFF8B6B4A),
    TaskStatus.inProgress => const Color(0xFF2F7FA3),
    TaskStatus.completed => const Color(0xFF2E8B57),
  };

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    int? userId,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      priority: _priorityFromString((json['priority'] ?? 'medium') as String),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.tryParse(json['due_date'] as String),
      status: _statusFromString((json['status'] ?? 'pending') as String),
      userId: (json['user_id'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'status': status.name,
      'user_id': userId,
    };
  }

  static TaskPriority _priorityFromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.pending;
    }
  }
}
