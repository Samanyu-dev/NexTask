import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final taskProvider = NotifierProvider<TaskController, TaskState>(
  TaskController.new,
);

class TaskState {
  const TaskState({
    required this.tasks,
    required this.isLoading,
    required this.isSaving,
    required this.initialized,
    required this.searchQuery,
    required this.statusFilter,
    required this.errorMessage,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final bool isSaving;
  final bool initialized;
  final String searchQuery;
  final TaskStatus? statusFilter;
  final String? errorMessage;

  factory TaskState.initial() {
    return const TaskState(
      tasks: [],
      isLoading: false,
      isSaving: false,
      initialized: false,
      searchQuery: '',
      statusFilter: null,
      errorMessage: null,
    );
  }

  List<TaskModel> get visibleTasks {
    return tasks.where((task) {
      final matchesSearch =
          searchQuery.isEmpty ||
          task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFilter = statusFilter == null || task.status == statusFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? isSaving,
    bool? initialized,
    String? searchQuery,
    TaskStatus? statusFilter,
    String? errorMessage,
    bool clearError = false,
    bool clearStatusFilter = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      initialized: initialized ?? this.initialized,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TaskController extends Notifier<TaskState> {
  ApiService get _api => ref.read(apiServiceProvider);

  @override
  TaskState build() {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isAuthenticated) {
        state = TaskState.initial();
      }
    });

    return TaskState.initial();
  }

  Future<void> fetchTasks() async {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) {
      state = TaskState.initial();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _api.setAuthToken(token);
      final tasks = await _api.getTasks();
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        errorMessage: _cleanError(error),
      );
    }
  }

  Future<void> addTask(TaskModel task) async {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      _api.setAuthToken(token);
      final createdTask = await _api.createTask(task);
      state = state.copyWith(
        tasks: [createdTask, ...state.tasks],
        isSaving: false,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: _cleanError(error));
      rethrow;
    }
  }

  Future<void> editTask(TaskModel task) async {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      _api.setAuthToken(token);
      final updatedTask = await _api.updateTask(task);
      state = state.copyWith(
        tasks: [
          for (final item in state.tasks)
            if (item.id == updatedTask.id) updatedTask else item,
        ],
        isSaving: false,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: _cleanError(error));
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    final token = ref.read(authProvider).token;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      _api.setAuthToken(token);
      await _api.deleteTask(taskId);
      state = state.copyWith(
        tasks: state.tasks.where((task) => task.id != taskId).toList(),
        isSaving: false,
        initialized: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: _cleanError(error));
      rethrow;
    }
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setStatusFilter(TaskStatus? value) {
    if (value == null) {
      state = state.copyWith(clearStatusFilter: true);
      return;
    }
    state = state.copyWith(statusFilter: value);
  }

  TaskModel? getTaskById(int taskId) {
    for (final task in state.tasks) {
      if (task.id == taskId) {
        return task;
      }
    }
    return null;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
