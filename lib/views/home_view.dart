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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Phase Label
                      GetBuilder<TimerController>(
                        id: UiIds.ID_SESSION_INFO,
                        builder: (timerController) => AnimatedDefaultTextStyle(
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: _getPhaseColor(context, timerController),
                                fontWeight: FontWeight.w600,
                              ),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: Text(
                            timerController.currentPhaseLabel,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Circular Timer
                      const CircularTimer(),

                      const SizedBox(height: 40),

                      // Pomodoro Counter
                      GetBuilder<TimerController>(
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

                      const SizedBox(height: 32),

                      // Task Selector
                      const TaskSelector(),

                      const SizedBox(height: 16),

                      // Finish Task Button
                      GetBuilder<TimerController>(
                        id: UiIds.ID_SESSION_INFO,
                        builder: (timerController) =>
                            GetBuilder<TaskController>(
                          id: UiIds.ID_CURRENT_TASK_DISPLAY,
                          builder: (taskController) {
                            if (!timerController.isBreakPhase &&
                                taskController.selectedTask != null) {
                              return TextButton.icon(
                                onPressed: () {
                                  _finishTaskManually(context);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Terminar tarea actual'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Timer Controls
                      const TimerControls(),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
          ? const Color(0xFFFF9800) // Orange
          : const Color(0xFF2196F3); // Blue
    }
    return const Color(0xFF4CAF50); // Green
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

              // Mark task as complete
              if (!currentTask.isCompleted) {
                await taskController.toggleTaskCompletion(currentTask.id!);
              }

              // Trigger timer completion logic for transition
              // We might need a specific method in timer controller to "Finish and Transition"
              // reusing _onTimerComplete might double count the pomodoro if we are not careful?
              // "Finish task" usually implies "I'm done with the task, even if timer isn't up OR timer is up"
              // If we want to "trigger behavior", we should probably just treat it as "Session Complete" but specifically for Task.
              // Let's skip the remaining time and trigger complete.

              // Trigger timer completion logic for transition
              // We reset timer to 0 so next tick handles completion or we force it.
              timerController.remainingSeconds = 0;

              // We also explicitely skip to break to be sure functionality is triggered immediately
              // instead of waiting for next tick if paused.
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
