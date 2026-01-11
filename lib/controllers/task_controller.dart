import 'package:get/get.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  
  final tasks = <Task>[].obs;
  final selectedTask = Rxn<Task>();
  final completedTasksCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks.value = await _db.getAllTasks();
    _updateCompletedCount();
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
  }

  Future<void> toggleTaskCompletion(int taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;
    
    if (selectedTask.value?.id == taskId && updatedTask.isCompleted) {
      selectedTask.value = null;
    }
    
    _updateCompletedCount();
  }

  Future<void> deleteTask(int taskId) async {
    await _db.deleteTask(taskId);
    tasks.removeWhere((t) => t.id == taskId);
    
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = null;
    }
    
    _updateCompletedCount();
  }

  Future<void> incrementTaskPomodoro(int taskId) async {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final updatedTask = task.copyWith(
      completedPomodoros: task.completedPomodoros + 1,
      isCompleted: task.completedPomodoros + 1 >= task.estimatedPomodoros,
      completedAt: task.completedPomodoros + 1 >= task.estimatedPomodoros
          ? DateTime.now()
          : null,
    );

    await _db.updateTask(updatedTask);
    tasks[taskIndex] = updatedTask;
    
    if (selectedTask.value?.id == taskId) {
      selectedTask.value = updatedTask;
    }
    
    _updateCompletedCount();
  }

  void selectTask(Task? task) {
    selectedTask.value = task;
  }

  List<Task> get activeTasks => tasks.where((t) => !t.isCompleted).toList();
  
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  int get todayCompletedCount {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return tasks.where((task) {
      if (task.completedAt == null) return false;
      return task.completedAt!.isAfter(startOfDay);
    }).length;
  }

  void _updateCompletedCount() {
    completedTasksCount.value = todayCompletedCount;
  }
}
