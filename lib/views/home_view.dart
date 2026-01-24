import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/timer_controller.dart';
import '../controllers/task_controller.dart';
import '../core/ui_ids.dart';

import '../widgets/circular_timer.dart';
import '../widgets/timer_controls.dart';
import '../widgets/task_selector.dart';

import 'tasks_view.dart';
import 'stats_view.dart';
import 'settings_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.to(() => const SettingsView()),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final screenW = mq.size.width;

            // Mantengo tu fórmula de diámetro
            final base = screenW * 0.77;
            final timerDiameter = base.clamp(230.0, 290.0);

            // Alto disponible (sin appbar + safe areas + bottom nav)
            //final availableH = mq.size.height -
            //    mq.padding.top -
            //    mq.padding.bottom -
            //    kToolbarHeight -
            //    kBottomNavigationBarHeight;

            // Bloque superior fijo
            final bodyH = constraints.maxHeight;
            final timerBlockHeight = bodyH * 0.6;
            //final timerBlockHeight = availableH * 0.52;

            return Column(
              children: [
                // TIMER BLOCK (Fixed Height)
                SizedBox(
                  height: timerBlockHeight,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: GetBuilder<TimerController>(
                            id: UiIds.ID_SESSION_INFO,
                            builder: (timerController) =>
                                AnimatedDefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: _getPhaseColor(
                                      context,
                                      timerController,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: Text(timerController.currentPhaseLabel),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: CircularTimer(diameter: timerDiameter),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: GetBuilder<TimerController>(
                          id: UiIds.ID_SESSION_INFO,
                          builder: (timerController) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${timerController.completedPomodoros} Pomodoros completados',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainer
                          .withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        child: Column(
                          children: [
                            const TaskSelector(),
                            const SizedBox(height: 16),
                            GetBuilder<TimerController>(
                              id: UiIds.ID_SESSION_INFO,
                              builder: (timerController) =>
                                  GetBuilder<TaskController>(
                                id: UiIds.ID_CURRENT_TASK_DISPLAY,
                                builder: (taskController) {
                                  if (!timerController.isBreakPhase &&
                                      taskController.selectedTask != null) {
                                    return TextButton.icon(
                                      onPressed: () =>
                                          _finishTaskManually(context),
                                      icon: const Icon(Icons.check),
                                      label:
                                          const Text('Terminar tarea actual'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const TimerControls(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final currentIndex = _getCurrentIndex();
          return NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer),
                label: 'Timer',
              ),
              NavigationDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt),
                label: 'Tareas',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Estadísticas',
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getPhaseColor(BuildContext context, TimerController controller) {
    if (controller.isBreakPhase) {
      return controller.currentBreakType == BreakType.longBreak
          ? const Color(0xFFFF9800)
          : const Color(0xFF2196F3);
    }
    return const Color(0xFF4CAF50);
  }

  void _finishTaskManually(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final timerController = Get.find<TimerController>();
    final currentTask = taskController.selectedTask;

    if (currentTask == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Terminar tarea?'),
        content: Text(
          '¿Seguro que quieres marcar "${currentTask.title}" como completada y terminar el pomodoro actual?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              if (!currentTask.isCompleted) {
                await taskController.toggleTaskCompletion(currentTask.id!);
              }

              timerController.remainingSeconds = 0;
              timerController.skipToBreak();
            },
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex() {
    final currentRoute = Get.currentRoute;
    if (currentRoute.contains('tasks')) return 1;
    if (currentRoute.contains('stats')) return 2;
    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        if (Get.currentRoute != '/') {
          Get.back();
        }
        break;
      case 1:
        Get.to(() => const TasksView());
        break;
      case 2:
        Get.to(() => const StatsView());
        break;
    }
  }
}
