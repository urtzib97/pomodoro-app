import 'package:get/get.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';

class StatsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  final todayPomodoros = 0.obs;
  final weekPomodoros = 0.obs;
  final todaySessions = <PomodoroSession>[].obs;
  final weekSessions = <PomodoroSession>[].obs;
  final selectedPeriod = 'today'.obs; // 'today' or 'week'

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  Future<void> refreshStats() async {
    await loadTodayStats();
    await loadWeekStats();
  }

  Future<void> loadTodayStats() async {
    todayPomodoros.value = await _db.getCompletedPomodorosToday();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    todaySessions.value =
        await _db.getSessionsByDateRange(startOfDay, endOfDay);
  }

  Future<void> loadWeekStats() async {
    weekPomodoros.value = await _db.getCompletedPomodorosThisWeek();

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    weekSessions.value = await _db.getSessionsByDateRange(
      startOfWeekDay,
      now,
    );
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
  }

  List<PomodoroSession> get currentSessions {
    return selectedPeriod.value == 'today' ? todaySessions : weekSessions;
  }

  int get currentPomodoros {
    return selectedPeriod.value == 'today'
        ? todayPomodoros.value
        : weekPomodoros.value;
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
    if (selectedPeriod.value != 'week') return {};

    final Map<String, int> breakdown = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      final dayKey = _formatDay(day);
      breakdown[dayKey] = 0;
    }

    for (final session in weekSessions) {
      if (session.completed && session.type == 'work') {
        final dayKey = _formatDay(session.startTime);
        breakdown[dayKey] = (breakdown[dayKey] ?? 0) + 1;
      }
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
