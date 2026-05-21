import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import 'custom_button.dart';
import 'custom_textfield.dart';
import 'selection_sheet_field.dart';

class TaskFormValue {
  TaskFormValue({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
  });

  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
}

class TaskFormWidget extends StatefulWidget {
  const TaskFormWidget({
    super.key,
    required this.onSubmit,
    this.initialTask,
    this.submitLabel = 'Save task',
    this.isLoading = false,
  });

  final TaskModel? initialTask;
  final ValueChanged<TaskFormValue> onSubmit;
  final String submitLabel;
  final bool isLoading;

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;

  static const List<SelectionOption<TaskPriority>> _priorityOptions = [
    SelectionOption<TaskPriority>(
      value: TaskPriority.high,
      label: 'High',
      caption: 'Urgent work with visible impact.',
      color: Color(0xFFC44536),
      icon: Icons.keyboard_double_arrow_up_rounded,
    ),
    SelectionOption<TaskPriority>(
      value: TaskPriority.medium,
      label: 'Medium',
      caption: 'Important work with balanced urgency.',
      color: Color(0xFFE08A1E),
      icon: Icons.remove_rounded,
    ),
    SelectionOption<TaskPriority>(
      value: TaskPriority.low,
      label: 'Low',
      caption: 'Lower urgency items you can batch later.',
      color: Color(0xFF2E8B57),
      icon: Icons.keyboard_double_arrow_down_rounded,
    ),
  ];

  static const List<SelectionOption<TaskStatus>> _statusOptions = [
    SelectionOption<TaskStatus>(
      value: TaskStatus.pending,
      label: 'Pending',
      caption: 'Not started yet.',
      color: Color(0xFF8B6B4A),
      icon: Icons.hourglass_bottom_rounded,
    ),
    SelectionOption<TaskStatus>(
      value: TaskStatus.inProgress,
      label: 'In Progress',
      caption: 'Currently being worked on.',
      color: Color(0xFF2F7FA3),
      icon: Icons.timelapse_rounded,
    ),
    SelectionOption<TaskStatus>(
      value: TaskStatus.completed,
      label: 'Completed',
      caption: 'Finished and ready to review.',
      color: Color(0xFF2E8B57),
      icon: Icons.check_circle_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _priority = task?.priority ?? TaskPriority.medium;
    _status = task?.status ?? TaskStatus.pending;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task essentials', style: theme.textTheme.titleLarge),
          const SizedBox(height: 18),
          CustomTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Quarterly review prep',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 5,
            label: 'Description',
            hint: 'Add context, owners, and what success looks like.',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SelectionSheetField<TaskPriority>(
            label: 'Priority',
            sheetTitle: 'Choose priority',
            selectedValue: _priority,
            options: _priorityOptions,
            leadingIcon: Icons.flag_rounded,
            helperText:
                'Set urgency clearly so the dashboard feels intentional.',
            onSelected: (value) => setState(() => _priority = value),
          ),
          const SizedBox(height: 16),
          SelectionSheetField<TaskStatus>(
            label: 'Status',
            sheetTitle: 'Choose status',
            selectedValue: _status,
            options: _statusOptions,
            leadingIcon: Icons.pie_chart_rounded,
            helperText: 'Keep progress accurate for a cleaner workflow.',
            onSelected: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickDate,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'Pick due date'
                          : DateFormat('dd MMM yyyy').format(_dueDate!),
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      onPressed: () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: widget.submitLabel,
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.onSubmit(
      TaskFormValue(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      ),
    );
  }
}
