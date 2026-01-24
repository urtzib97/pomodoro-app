import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/ui_ids.dart';
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

  // State
  TimerState timerState = TimerState.idle;
  int remainingSeconds = 0;
  int totalSeconds = 0;
  int completedPomodoros = 0;
  BreakType currentBreakType = BreakType.none;

  Timer? _timer;
  PomodoroSession? _currentSession;

  bool get isBreakPhase => currentBreakType != BreakType.none;

  int get currentCycle =>
      completedPomodoros % _settings.pomodorosBeforeLongBreak;

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
    totalSeconds = _settings.workDuration * 60;
    remainingSeconds = totalSeconds;
    update([UiIds.ID_TIMER_TEXT, UiIds.ID_TIMER_PROGRESS]);
  }

  void startTimer() {
    if (timerState == TimerState.running) return;

    if (timerState == TimerState.idle || timerState == TimerState.breakTime) {
      _startNewSession();
    }

    timerState = TimerState.running;
    update([UiIds.ID_TIMER_CONTROLS]);
    _runTimer();
  }

  void pauseTimer() {
    if (timerState != TimerState.running) return;

    _timer?.cancel();
    timerState = TimerState.paused;
    update([UiIds.ID_TIMER_CONTROLS]);
  }

  void resetTimer() {
    _timer?.cancel();
    timerState = TimerState.idle;
    currentBreakType = BreakType.none;

    totalSeconds = _settings.workDuration * 60;
    remainingSeconds = totalSeconds;

    _currentSession = null;

    update([
      UiIds.ID_TIMER_TEXT,
      UiIds.ID_TIMER_PROGRESS,
      UiIds.ID_TIMER_CONTROLS,
      UiIds.ID_SESSION_INFO,
    ]);
  }

  void skipToBreak() {
    if (timerState == TimerState.breakTime) return;

    _timer?.cancel();
    _completeCurrentSession();
    _startBreak();
  }

  void skipBreak() {
    if (!isBreakPhase) return;

    _timer?.cancel();
    _completeCurrentSession();
    resetTimer();
  }

  void _runTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        // Optimized update: only timer text and progress
        update([UiIds.ID_TIMER_TEXT, UiIds.ID_TIMER_PROGRESS]);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _startNewSession() {
    final isBreak = timerState == TimerState.breakTime;
    final duration = isBreak
        ? (currentBreakType == BreakType.longBreak
            ? _settings.longBreakDuration
            : _settings.shortBreakDuration)
        : _settings.workDuration;

    totalSeconds = duration * 60;
    remainingSeconds = totalSeconds;

    _currentSession = PomodoroSession(
      taskId: _tasks.selectedTask?.id,
      startTime: DateTime.now(),
      duration: duration,
      type: isBreak
          ? (currentBreakType == BreakType.longBreak
              ? 'longBreak'
              : 'shortBreak')
          : 'work',
    );

    // Update all relevant UI
    update(
      [UiIds.ID_TIMER_TEXT, UiIds.ID_TIMER_PROGRESS, UiIds.ID_SESSION_INFO],
    );
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();

    await _completeCurrentSession();

    if (isBreakPhase) {
      await NotificationService.showNotification(
        title: '¡Descanso completado!',
        body: '¿Listo para otro pomodoro?',
        playSound: _settings.soundEnabled,
      );

      // Check if we should auto-start pomodoro
      if (_settings.autoStartPomodoros) {
        resetTimer();
        Future.delayed(const Duration(seconds: 2), () => startTimer());
      } else {
        resetTimer();
      }
    } else {
      // Work session completed
      completedPomodoros++;
      update([UiIds.ID_SESSION_INFO]);

      final currentTask = _tasks.selectedTask;
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
    final behavior = _settings.taskCompletionBehavior;

    if (behavior == 'auto') {
      final nextTask =
          _tasks.activeTasks.isNotEmpty ? _tasks.activeTasks.first : null;
      if (nextTask != null) {
        _tasks.selectTask(nextTask);
        _startBreak();
      } else {
        _startBreak();
      }
    } else if (behavior == 'continue') {
      _tasks.selectTask(null);
      _startBreak();
    } else {
      await _showTaskCompletedDialog();
    }
  }

  Future<void> _showTaskCompletedDialog() async {
    await NotificationService.showNotification(
      title: '¡Tarea completada!',
      body: 'Has alcanzado el objetivo de pomodoros para esta tarea.',
      playSound: _settings.soundEnabled,
    );

    await Get.dialog(
      AlertDialog(
        title: const Text('¡Tarea completada!'),
        content: const Text('¿Qué quieres hacer a continuación?'),
        actions: [
          TextButton(
            onPressed: () {
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
        completedPomodoros % _settings.pomodorosBeforeLongBreak == 0;

    currentBreakType =
        shouldTakeLongBreak ? BreakType.longBreak : BreakType.shortBreak;

    timerState = TimerState.breakTime;

    final breakDuration = shouldTakeLongBreak
        ? _settings.longBreakDuration
        : _settings.shortBreakDuration;

    NotificationService.showNotification(
      title: '¡Pomodoro completado!',
      body: shouldTakeLongBreak
          ? '¡Excelente trabajo! Toma un descanso largo de $breakDuration minutos.'
          : 'Toma un descanso corto de $breakDuration minutos.',
      playSound: _settings.soundEnabled,
    );

    _startNewSession();
    update([
      UiIds.ID_TIMER_CONTROLS,
      UiIds.ID_SESSION_INFO,
      UiIds.ID_TIMER_TEXT,
      UiIds.ID_TIMER_PROGRESS,
    ]);

    if (_settings.autoStartBreaks) {
      Future.delayed(const Duration(seconds: 2), () {
        _startNewSession();
        startTimer();
      });
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
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  String get currentPhaseLabel {
    if (isBreakPhase) {
      return currentBreakType == BreakType.longBreak
          ? 'Descanso Largo'
          : 'Descanso Corto';
    }
    return 'Enfoque';
  }

  // Exposed for Views to trigger full update if needed (e.g. initial load)
  void refreshUI() {
    update([
      UiIds.ID_TIMER_TEXT,
      UiIds.ID_TIMER_PROGRESS,
      UiIds.ID_TIMER_CONTROLS,
      UiIds.ID_SESSION_INFO,
    ]);
  }
}
