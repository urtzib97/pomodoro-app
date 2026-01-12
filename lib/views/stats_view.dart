import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/stats_controller.dart';
import '../models/pomodoro_session.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = Get.find<StatsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => statsController.refreshStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  Obx(
                    () => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'today',
                          label: Text('Hoy'),
                          icon: Icon(Icons.today),
                        ),
                        ButtonSegment(
                          value: 'week',
                          label: Text('Semana'),
                          icon: Icon(Icons.calendar_view_week),
                        ),
                      ],
                      selected: {statsController.selectedPeriod.value},
                      onSelectionChanged: (Set<String> selected) {
                        statsController.setPeriod(selected.first);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary Cards
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Pomodoros',
                            value: '${statsController.currentPomodoros}',
                            icon: Icons.timer,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Minutos',
                            value: '${statsController.totalMinutes}',
                            icon: Icons.access_time,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Obx(
                    () => _buildStatCard(
                      context,
                      title: 'Tasa de completación',
                      value:
                          '${statsController.completionRate.toStringAsFixed(0)}%',
                      subtitle: statsController.completionRateFormula,
                      icon: Icons.trending_up,
                      color: Theme.of(context).colorScheme.tertiary,
                      isFullWidth: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Weekly Chart (only for week view)
                  Obx(() {
                    if (statsController.selectedPeriod.value == 'week') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actividad semanal',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildWeeklyChart(context, statsController),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Session History
                  Text(
                    'Historial',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Obx(() {
                    final sessions = statsController.workSessions;

                    if (sessions.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay sesiones registradas',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: sessions
                          .map((session) => _buildSessionCard(context, session))
                          .toList(),
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: isFullWidth
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: isFullWidth
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, StatsController controller) {
    final breakdown = controller.dailyBreakdown;
    final maxValue = breakdown.values.isEmpty
        ? 1
        : breakdown.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: breakdown.entries.map((entry) {
            final height = maxValue > 0 ? (entry.value / maxValue) * 100 : 0.0;
            return Column(
              children: [
                Text(
                  '${entry.value}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: height.clamp(20.0, 100.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, PomodoroSession session) {
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text('${session.duration} minutos'),
        subtitle: Text(timeFormat.format(session.startTime)),
        trailing: session.endTime != null
            ? Text(
                timeFormat.format(session.endTime!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              )
            : null,
      ),
    );
  }
}
