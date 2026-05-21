import 'package:flutter/material.dart';

import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.authProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = widget.taskProvider.visibleTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              widget.taskProvider.clear();
              await widget.authProvider.logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(taskProvider: widget.taskProvider),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F3EC), Color(0xFFF1F7F4), Color(0xFFFDF8F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF123C35),
                      Color(0xFF2E6C59),
                      Color(0xFFE08A1E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF123C35).withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task command center',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Track urgent work, keep visibility high, and make progress feel tangible.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatPill(
                          label: 'Total',
                          value: '${widget.taskProvider.tasks.length}',
                        ),
                        _StatPill(
                          label: 'Pending',
                          value:
                              '${widget.taskProvider.tasks.where((task) => task.status == TaskStatus.pending).length}',
                        ),
                        _StatPill(
                          label: 'Completed',
                          value:
                              '${widget.taskProvider.tasks.where((task) => task.status == TaskStatus.completed).length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: widget.taskProvider.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search tasks, notes, or owners',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<TaskStatus?>(
                initialValue: widget.taskProvider.statusFilter,
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
                onChanged: widget.taskProvider.setStatusFilter,
              ),
              const SizedBox(height: 20),
              if (widget.taskProvider.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (tasks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_rounded, size: 42),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks match right now',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try another search, clear the filter, or create a fresh task.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TaskCard(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskDetailsScreen(
                              taskProvider: widget.taskProvider,
                              taskId: task.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadTasks() async {
    final token = widget.authProvider.token;
    if (token == null || token.isEmpty) {
      return;
    }
    await widget.taskProvider.fetchTasks(token);
    if (!mounted) {
      return;
    }
    final error = widget.taskProvider.error;
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
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
