import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskService);

  final TaskService _taskService;

  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  List<TaskItem> _tasks = [];

  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  List<TaskItem> get visibleTasks {
    return _tasks.where((task) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _statusFilter == null || task.status == _statusFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> fetchTasks(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.fetchTasks(token);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void addTask(TaskItem task) {
    _tasks = [task, ..._tasks];
    notifyListeners();
  }

  void updateTask(TaskItem updatedTask) {
    _tasks = _tasks
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();
    notifyListeners();
  }

  void deleteTask(int taskId) {
    _tasks = _tasks.where((task) => task.id != taskId).toList();
    notifyListeners();
  }

  void clear() {
    _tasks = [];
    _searchQuery = '';
    _statusFilter = null;
    _error = null;
    notifyListeners();
  }

  int nextId() {
    if (_tasks.isEmpty) {
      return 1;
    }
    return _tasks.map((task) => task.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
