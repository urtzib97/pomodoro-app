import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/ui_ids.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';

class StatsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  int todayPomodoros = 0;
  int weekPomodoros = 0;
  List<PomodoroSession> todaySessions = [];
  List<PomodoroSession> weekSessions = [];
  Map<DateTime, int> weekDailyCountsByDate = {};
  String selectedPeriod = 'today'; // 'today' or 'week'

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  Future<void> refreshStats() async {
    await loadTodayStats();
    await loadWeekStats();
    update([UiIds.ID_STATS_SUMMARY, UiIds.ID_STATS_CHART]);
  }

  Future<void> loadTodayStats() async {
    todayPomodoros = await _db.getCompletedPomodorosToday();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final nextDayStart = startOfDay.add(const Duration(days: 1));

    todaySessions = await _db.getSessionsByDateRange(startOfDay, nextDayStart);
  }

  Future<void> loadWeekStats() async {
    weekPomodoros = await _db.getCompletedPomodorosThisWeek();

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateUtils.dateOnly(startOfWeek);
    final nextDayStart = DateUtils.dateOnly(now).add(const Duration(days: 1));

    weekSessions = await _db.getSessionsByDateRange(
      startOfWeekDay,
      nextDayStart,
    );

    weekDailyCountsByDate = await _db.getCompletedWorkSessionsCountByDay(
      startOfWeekDay,
      nextDayStart,
    );
  }

  void setPeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    update([UiIds.ID_STATS_SUMMARY, UiIds.ID_STATS_CHART]);
  }

  List<PomodoroSession> get currentSessions {
    return selectedPeriod == 'today' ? todaySessions : weekSessions;
  }

  int get currentPomodoros {
    return selectedPeriod == 'today' ? todayPomodoros : weekPomodoros;
  }

  int get totalMinutes {
    final sessions =
        currentSessions.where((s) => s.completed && s.type == 'work');
    return sessions.fold(0, (sum, session) => sum + session.duration);
  }

  double get completionRate {
    final total = currentSessions.where((s) => s.type == 'work').length;
    if (total == 0) return 0.0;

    final completed =
        currentSessions.where((s) => s.completed && s.type == 'work').length;
    return (completed / total) * 100;
  }

  String get completionRateFormula {
    final total = currentSessions.where((s) => s.type == 'work').length;
    final completed =
        currentSessions.where((s) => s.completed && s.type == 'work').length;
    return '$completed / $total sesiones';
  }

  Map<String, int> get dailyBreakdown {
    if (selectedPeriod != 'week') return {};

    final Map<String, int> breakdown = {};
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateUtils.dateOnly(startOfWeek);

    for (int i = 0; i < 7; i++) {
      final day = DateUtils.dateOnly(startOfWeekDay.add(Duration(days: i)));
      final label = _formatDay(day);
      breakdown[label] = weekDailyCountsByDate[day] ?? 0;
    }

    return breakdown;
  }

  String _formatDay(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  List<PomodoroSession> get workSessions {
    return currentSessions
        .where((s) => s.type == 'work' && s.completed)
        .toList();
  }
}
