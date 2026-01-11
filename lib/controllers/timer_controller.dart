import 'dart:async';
import 'package:get/get.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'settings_controller.dart';
import 'task_controller.dart';
import 'stats_controller.dart';

enum TimerState { idle, running, paused, break_time }
enum BreakType { none, short_break, long_break }

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

  int get currentCycle => completedPomodoros.value % _settings.pomodorosBeforeLongBreak.value;

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

    if (timerState.value == TimerState.idle || timerState.value == TimerState.break_time) {
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
    if (timerState.value == TimerState.break_time) return;
    
    _timer?.cancel();
    _completeCurrentSession();
    _startBreak();
  }

  void skipBreak() {
    if (timerState.value != TimerState.break_time) return;
    
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
    final isBreak = timerState.value == TimerState.break_time;
    final duration = isBreak
        ? (currentBreakType.value == BreakType.long_break
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
          ? (currentBreakType.value == BreakType.long_break ? 'long_break' : 'short_break')
          : 'work',
    );
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    
    await _completeCurrentSession();

    if (timerState.value == TimerState.break_time) {
      // Break completed, return to idle
      currentBreakType.value = BreakType.none;
      timerState.value = TimerState.idle;
      
      await NotificationService.showNotification(
        title: '¡Descanso completado!',
        body: '¿Listo para otro pomodoro?',
        playSound: _settings.soundEnabled.value,
      );

      if (_settings.autoStartPomodoros.value) {
        resetTimer();
        Future.delayed(const Duration(seconds: 2), () => startTimer());
      } else {
        resetTimer();
      }
    } else {
      // Work session completed
      completedPomodoros.value++;
      
      if (_tasks.selectedTask.value != null) {
        await _tasks.incrementTaskPomodoro(_tasks.selectedTask.value!.id!);
      }
      
      await _stats.refreshStats();
      _startBreak();
    }
  }

  void _startBreak() {
    final shouldTakeLongBreak = 
        completedPomodoros.value % _settings.pomodorosBeforeLongBreak.value == 0;
    
    currentBreakType.value = shouldTakeLongBreak 
        ? BreakType.long_break 
        : BreakType.short_break;
    
    timerState.value = TimerState.break_time;

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
    if (timerState.value == TimerState.break_time) {
      return currentBreakType.value == BreakType.long_break
          ? 'Descanso Largo'
          : 'Descanso Corto';
    }
    return 'Enfoque';
  }
}
