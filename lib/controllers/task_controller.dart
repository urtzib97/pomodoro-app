import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/ui_ids.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  List<Task> tasks = [];
  Task? selectedTask;
  int completedTasksCount = 0;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await _db.getAllTasks();
    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<void> addTask(String title, int estimatedPomodoros) async {
    final task = Task(
      title: title,
      estimatedPomodoros: estimatedPomodoros,
    );

    final id = await _db.insertTask(task);
    final newTask = task.copyWith(id: id);
    tasks.insert(0, newTask);
    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<void> toggleTaskCompletion(BuildContext context, int taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];

    // If undoing completion, ask for confirmation
    if (task.isCompleted) {
      final confirmed = await _showUndoConfirmation(context);
      if (confirmed != true) {
        return;
      }
    }

    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;

    // Only deselect if it matches the currently selected task
    if (selectedTask?.id == taskId && updatedTask.isCompleted) {
      selectedTask = null;
      update([UiIds.ID_CURRENT_TASK_DISPLAY]);
    }

    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<bool?> _showUndoConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desmarcar tarea'),
        content: const Text(
          '¿Estás seguro de que quieres desmarcar esta tarea como completada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desmarcar'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteTask(int taskId) async {
    await _db.deleteTask(taskId);
    tasks.removeWhere((t) => t.id == taskId);

    if (selectedTask?.id == taskId) {
      selectedTask = null;
      update([UiIds.ID_CURRENT_TASK_DISPLAY]);
    }

    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<void> incrementTaskPomodoro(int taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final newCompletedPomodoros = task.completedPomodoros + 1;
    final isNowCompleted = task.estimatedPomodoros > 0 &&
        newCompletedPomodoros >= task.estimatedPomodoros;

    final updatedTask = task.copyWith(
      completedPomodoros: newCompletedPomodoros,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;

    if (selectedTask?.id == taskId) {
      // Keep selected but update its state in memory so timer knows
      selectedTask = updatedTask;
      update([UiIds.ID_CURRENT_TASK_DISPLAY]);
    }

    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<void> decrementTaskPomodoro(int taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    if (task.completedPomodoros <= 0) return;

    final newCompletedPomodoros = task.completedPomodoros - 1;

    final updatedTask = task.copyWith(
      completedPomodoros: newCompletedPomodoros,
      isCompleted: false, // Uncheck if decremented
      completedAt: null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;

    if (selectedTask?.id == taskId) {
      selectedTask = updatedTask;
      update([UiIds.ID_CURRENT_TASK_DISPLAY]);
    }

    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  Future<void> updateTaskEstimate(int taskId, int newEstimate) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final isNowCompleted = task.completedPomodoros >= newEstimate;

    final updatedTask = task.copyWith(
      estimatedPomodoros: newEstimate,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? (task.completedAt ?? DateTime.now()) : null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;

    if (selectedTask?.id == taskId) {
      selectedTask = updatedTask;
      update([UiIds.ID_CURRENT_TASK_DISPLAY]);
    }

    _updateCompletedCount();
    update([UiIds.ID_TASK_LIST, UiIds.ID_STATS_SUMMARY]);
  }

  void selectTask(Task? task) {
    if (selectedTask?.id == task?.id) return; // No change
    selectedTask = task;
    update([UiIds.ID_CURRENT_TASK_DISPLAY]);
  }

  List<Task> get activeTasks => tasks.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  int get todayCompletedCount {
    final now = DateTime.now();

    return tasks.where((task) {
      if (task.completedAt == null) return false;
      final completedDate = task.completedAt!;
      return completedDate.year == now.year &&
          completedDate.month == now.month &&
          completedDate.day == now.day;
    }).length;
  }

  void _updateCompletedCount() {
    completedTasksCount = todayCompletedCount;
  }
}
