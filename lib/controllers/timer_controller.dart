import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'settings_controller.dart';
import 'task_controller.dart';
import 'stats_controller.dart';

enum TimerState { idle, running, paused, breakTime }

enum BreakType { none, shortBreak, longBreak }

class TimerController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  final SettingsController _settings = Get.find<SettingsController>();
  final TaskController _tasks = Get.find<TaskController>();
  final StatsController _stats = Get.find<StatsController>();

  // Observable state
  final timerState = TimerState.idle.obs;
  final remainingSeconds = 0.obs;
  final totalSeconds = 0.obs;
  final completedPomodoros = 0.obs;
  final currentBreakType = BreakType.none.obs;

  Timer? _timer;
  PomodoroSession? _currentSession;

  int get currentCycle =>
      completedPomodoros.value % _settings.pomodorosBeforeLongBreak.value;

  @override
  void onInit() {
    super.onInit();
    _initializeTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _initializeTimer() {
    totalSeconds.value = _settings.workDuration.value * 60;
    remainingSeconds.value = totalSeconds.value;
  }

  void startTimer() {
    if (timerState.value == TimerState.running) return;

    if (timerState.value == TimerState.idle ||
        timerState.value == TimerState.breakTime) {
      _startNewSession();
    }

    timerState.value = TimerState.running;
    _runTimer();
  }

  void pauseTimer() {
    if (timerState.value != TimerState.running) return;

    _timer?.cancel();
    timerState.value = TimerState.paused;
  }

  void resetTimer() {
    _timer?.cancel();
    timerState.value = TimerState.idle;
    currentBreakType.value = BreakType.none;

    totalSeconds.value = _settings.workDuration.value * 60;
    remainingSeconds.value = totalSeconds.value;

    _currentSession = null;
  }

  void skipToBreak() {
    if (timerState.value == TimerState.breakTime) return;

    _timer?.cancel();
    _completeCurrentSession();
    _startBreak();
  }

  void skipBreak() {
    if (timerState.value != TimerState.breakTime) return;

    _timer?.cancel();
    _completeCurrentSession();
    resetTimer();
  }

  void _runTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _onTimerComplete();
      }
    });
  }

  void _startNewSession() {
    final isBreak = timerState.value == TimerState.breakTime;
    final duration = isBreak
        ? (currentBreakType.value == BreakType.longBreak
            ? _settings.longBreakDuration.value
            : _settings.shortBreakDuration.value)
        : _settings.workDuration.value;

    totalSeconds.value = duration * 60;
    remainingSeconds.value = totalSeconds.value;

    _currentSession = PomodoroSession(
      taskId: _tasks.selectedTask.value?.id,
      startTime: DateTime.now(),
      duration: duration,
      type: isBreak
          ? (currentBreakType.value == BreakType.longBreak
              ? 'longBreak'
              : 'shortBreak')
          : 'work',
    );
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();

    await _completeCurrentSession();

    if (timerState.value == TimerState.breakTime) {
      // Break completed, return to idle
      currentBreakType.value = BreakType.none;
      timerState.value = TimerState.idle;

      await NotificationService.showNotification(
        title: '¡Descanso completado!',
        body: '¿Listo para otro pomodoro?',
        playSound: _settings.soundEnabled.value,
      );

      // Check if we should auto-start pomodoro
      if (_settings.autoStartPomodoros.value) {
        resetTimer();
        Future.delayed(const Duration(seconds: 2), () => startTimer());
      } else {
        resetTimer();
      }
    } else {
      // Work session completed
      completedPomodoros.value++;

      final currentTask = _tasks.selectedTask.value;
      bool taskCompletedNow = false;

      if (currentTask != null) {
        // Increment pomodoros for the task
        await _tasks.incrementTaskPomodoro(currentTask.id!);

        // Refresh local task variable to check isCompleted status
        final updatedTask =
            _tasks.tasks.firstWhere((t) => t.id == currentTask.id);

        if (updatedTask.isCompleted) {
          taskCompletedNow = true;
        }
      }

      await _stats.refreshStats();

      if (taskCompletedNow) {
        await _handleTaskCompletion();
      } else {
        _startBreak();
      }
    }
  }

  Future<void> _handleTaskCompletion() async {
    final behavior = _settings.taskCompletionBehavior.value;

    if (behavior == 'auto') {
      // Select next available task
      final nextTask =
          _tasks.activeTasks.isNotEmpty ? _tasks.activeTasks.first : null;
      if (nextTask != null) {
        _tasks.selectTask(nextTask);
        // Do not take a break, just continue? Or take a break then next task?
        // "Next task auto" implies flow. Let's take the break first, but ensure next task is selected.
        _startBreak();
      } else {
        // No more tasks, just break
        _startBreak();
      }
    } else if (behavior == 'continue') {
      // Continue with no task selected
      _tasks.selectTask(null);
      _startBreak();
    } else {
      // 'ask' - Show dialog
      // We need to trigger a UI event. Since we are in controller,
      // we can use Get.dialog
      await _showTaskCompletedDialog();
    }
  }

  Future<void> _showTaskCompletedDialog() async {
    // Play sound first
    await NotificationService.showNotification(
      title: '¡Tarea completada!',
      body: 'Has alcanzado el objetivo de pomodoros para esta tarea.',
      playSound: _settings.soundEnabled.value,
    );

    // We pause/idle temporarily while dialog is shown?
    // Actually, we are technically between work and break.

    await Get.dialog(
      AlertDialog(
        title: const Text('¡Tarea completada!'),
        content: const Text('¿Qué quieres hacer a continuación?'),
        actions: [
          TextButton(
            onPressed: () {
              // Just take a break, keep task selected (maybe add more time?)
              Get.back();
              _startBreak();
            },
            child: const Text('Solo descanso'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              _tasks.selectTask(null);
              _startBreak();
            },
            child: const Text('Terminar tarea'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _startBreak() {
    final shouldTakeLongBreak =
        completedPomodoros.value % _settings.pomodorosBeforeLongBreak.value ==
            0;

    currentBreakType.value =
        shouldTakeLongBreak ? BreakType.longBreak : BreakType.shortBreak;

    timerState.value = TimerState.breakTime;

    final breakDuration = shouldTakeLongBreak
        ? _settings.longBreakDuration.value
        : _settings.shortBreakDuration.value;

    NotificationService.showNotification(
      title: '¡Pomodoro completado!',
      body: shouldTakeLongBreak
          ? '¡Excelente trabajo! Toma un descanso largo de $breakDuration minutos.'
          : 'Toma un descanso corto de $breakDuration minutos.',
      playSound: _settings.soundEnabled.value,
    );

    if (_settings.autoStartBreaks.value) {
      Future.delayed(const Duration(seconds: 2), () {
        _startNewSession();
        startTimer();
      });
    } else {
      _startNewSession();
    }
  }

  Future<void> _completeCurrentSession() async {
    if (_currentSession != null) {
      final completedSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        completed: true,
      );

      await _db.insertSession(completedSession);
      _currentSession = null;
    }
  }

  String get formattedTime {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds.value == 0) return 0.0;
    return 1.0 - (remainingSeconds.value / totalSeconds.value);
  }

  String get currentPhaseLabel {
    if (timerState.value == TimerState.breakTime) {
      return currentBreakType.value == BreakType.longBreak
          ? 'Descanso Largo'
          : 'Descanso Corto';
    }
    return 'Enfoque';
  }
}
