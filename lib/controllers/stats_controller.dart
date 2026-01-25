import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/ui_ids.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';

class StatsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  int todayPomodoros = 0;
  int todayTotalWorkSessions = 0;
  int todayWorkMinutes = 0;
  int weekPomodoros = 0;
  int weekTotalWorkSessions = 0;
  int weekWorkMinutes = 0;
  List<PomodoroSession> todaySessions = [];
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
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final nextDayStart = startOfDay.add(const Duration(days: 1));

    final stats =
        await _db.getWorkSessionStatsByRange(startOfDay, nextDayStart);
    todayPomodoros = stats['completedCount'] ?? 0;
    todayTotalWorkSessions = stats['totalCount'] ?? 0;
    todayWorkMinutes = stats['totalMinutes'] ?? 0;

    todaySessions = await _db.getSessionsByDateRange(startOfDay, nextDayStart);
  }

  Future<void> loadWeekStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateUtils.dateOnly(startOfWeek);
    final nextDayStart = DateUtils.dateOnly(now).add(const Duration(days: 1));

    final stats = await _db.getWorkSessionStatsByRange(
      startOfWeekDay,
      nextDayStart,
    );
    weekPomodoros = stats['completedCount'] ?? 0;
    weekTotalWorkSessions = stats['totalCount'] ?? 0;
    weekWorkMinutes = stats['totalMinutes'] ?? 0;

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

  int get currentPomodoros {
    return selectedPeriod == 'today' ? todayPomodoros : weekPomodoros;
  }

  int get totalMinutes {
    return selectedPeriod == 'today' ? todayWorkMinutes : weekWorkMinutes;
  }

  double get completionRate {
    final total = selectedPeriod == 'today'
        ? todayTotalWorkSessions
        : weekTotalWorkSessions;
    if (total == 0) return 0.0;

    final completed =
        selectedPeriod == 'today' ? todayPomodoros : weekPomodoros;
    return (completed / total) * 100;
  }

  String get completionRateFormula {
    final total = selectedPeriod == 'today'
        ? todayTotalWorkSessions
        : weekTotalWorkSessions;
    final completed =
        selectedPeriod == 'today' ? todayPomodoros : weekPomodoros;
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
    if (selectedPeriod == 'week') return [];
    return todaySessions.where((s) => s.type == 'work' && s.completed).toList();
  }
}
