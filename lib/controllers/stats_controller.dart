import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/ui_ids.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';

class StatsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  // Today
  int todayPomodoros = 0;
  int todayTotalWorkSessions = 0;
  int todayWorkMinutes = 0;
  List<PomodoroSession> todaySessions = [];

  // Week
  int weekPomodoros = 0;
  int weekTotalWorkSessions = 0;
  int weekWorkMinutes = 0;
  Map<DateTime, int> weekDailyCountsByDate = {};

  // Cached periods (boundaries computed on refresh)
  DateTime? _todayStart;
  DateTime? _todayEndExclusive;
  DateTime? _weekStart;
  DateTime? _weekEndExclusive;

  // Cached view model for the chart to avoid recomputing it in a getter
  Map<String, int> _weeklyBreakdownLabels = const {};

  String selectedPeriod = 'today'; // 'today' or 'week'

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  Future<void> refreshStats() async {
    // Take a single "now" snapshot for consistency across all calculations.
    final now = DateTime.now();

    _todayStart = DateUtils.dateOnly(now);
    _todayEndExclusive = _todayStart!.add(const Duration(days: 1));

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateUtils.dateOnly(startOfWeek);
    _weekEndExclusive = DateUtils.dateOnly(now).add(const Duration(days: 1));

    await loadTodayStats();
    await loadWeekStats();

    update([UiIds.ID_STATS_SUMMARY, UiIds.ID_STATS_CHART]);
  }

  Future<void> loadTodayStats() async {
    final start = _todayStart ?? DateUtils.dateOnly(DateTime.now());
    final endExclusive =
        _todayEndExclusive ?? start.add(const Duration(days: 1));

    final stats = await _db.getWorkSessionStatsByRange(start, endExclusive);
    todayPomodoros = stats['completedCount'] ?? 0;
    todayTotalWorkSessions = stats['totalCount'] ?? 0;
    todayWorkMinutes = stats['totalMinutes'] ?? 0;

    todaySessions = await _db.getSessionsByDateRange(start, endExclusive);
  }

  Future<void> loadWeekStats() async {
    final now = DateTime.now();
    final start = _weekStart ??
        DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    final endExclusive = _weekEndExclusive ??
        DateUtils.dateOnly(now).add(const Duration(days: 1));

    final stats = await _db.getWorkSessionStatsByRange(start, endExclusive);
    weekPomodoros = stats['completedCount'] ?? 0;
    weekTotalWorkSessions = stats['totalCount'] ?? 0;
    weekWorkMinutes = stats['totalMinutes'] ?? 0;

    weekDailyCountsByDate =
        await _db.getCompletedWorkSessionsCountByDay(start, endExclusive);

    // Precompute labels once, so the chart does not rebuild heavy logic.
    _weeklyBreakdownLabels = _buildWeeklyBreakdownLabels(start);
  }

  void setPeriod(String period) {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    update([UiIds.ID_STATS_SUMMARY, UiIds.ID_STATS_CHART]);
  }

  int get currentPomodoros =>
      selectedPeriod == 'today' ? todayPomodoros : weekPomodoros;

  int get totalMinutes =>
      selectedPeriod == 'today' ? todayWorkMinutes : weekWorkMinutes;

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

  /// For the weekly chart. Precomputed on loadWeekStats().
  Map<String, int> get dailyBreakdown {
    if (selectedPeriod != 'week') return {};
    return _weeklyBreakdownLabels;
  }

  Map<String, int> _buildWeeklyBreakdownLabels(DateTime weekStartDay) {
    final breakdown = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final day = DateUtils.dateOnly(weekStartDay.add(Duration(days: i)));
      final label = _formatDay(day);
      breakdown[label] = weekDailyCountsByDate[day] ?? 0;
    }
    return breakdown;
  }

  String _formatDay(DateTime date) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  /// History is only shown for today (week would be too noisy and we avoid fetching weekSessions).
  List<PomodoroSession> get workSessions {
    if (selectedPeriod == 'week') return const [];
    return todaySessions.where((s) => s.type == 'work' && s.completed).toList();
  }
}
