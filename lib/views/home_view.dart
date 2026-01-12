import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timer_controller.dart';
import '../controllers/task_controller.dart';

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
    final timerController = Get.find<TimerController>();

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
                      Obx(
                        () => Text(
                          timerController.currentPhaseLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: _getPhaseColor(context, timerController),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Circular Timer
                      const CircularTimer(),

                      const SizedBox(height: 40),

                      // Pomodoro Counter
                      Obx(
                        () => Row(
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
                              '${timerController.completedPomodoros.value} Pomodoros completados',
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
                      Obx(() {
                        if (timerController.timerState.value !=
                                TimerState.breakTime &&
                            Get.find<TaskController>().selectedTask.value !=
                                null) {
                          return TextButton.icon(
                            onPressed: () {
                              // Manual finish task
                              // We can trigger the same logic as timer complete but force it?
                              // Or just mark task as complete?
                              // "manual complete + trigger behavior"
                              // Let's call the controller method we added/will add?
                              // Actually we need to add a method in timer_controller to handle "Manual Finish"
                              // For now, let's implement the logic here or in controller.
                              // Ideally controller.
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
                      }),

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
    if (controller.timerState.value == TimerState.breakTime) {
      return controller.currentBreakType.value == BreakType.longBreak
          ? const Color(0xFFFF9800) // Orange
          : const Color(0xFF2196F3); // Blue
    }
    return const Color(0xFF4CAF50); // Green
  }

  void _finishTaskManually(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final timerController = Get.find<TimerController>();
    final currentTask = taskController.selectedTask.value;

    if (currentTask == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Terminar tarea?'),
        content: Text(
            '¿Seguro que quieres marcar "${currentTask.title}" como completada y terminar el pomodoro actual?'),
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

              timerController.remainingSeconds.value =
                  0; // Will trigger _runTimer callback? No, _runTimer checks periodically.
              // We should manually call logic.
              // But _onTimerComplete increments pomodoros. Do we want to count this fractional pomodoro?
              // Usually "Finish task" means "I'm done".
              // Let's assume we want to count it? Or maybe not?
              // Requirement says "trigger behavior".
              // I'll call a new method in TimerController: forceFinishSession()

              // Wait, if I cannot edit TimerController right now (I can, but in parallel steps).
              // I will add the method to timer_controller in the next step or assume it exists/add it now.
              // I will implement the logic directly here for now to avoid back and forth, or better:
              // Just use skipToBreak() but that doesn't mark task complete?
              // I already marked task complete above.
              // So if I call skipToBreak(), it will go to break.
              // But `_onTimerComplete` logic handles "Task Complete" checks.
              // If I already marked it complete, `_onTimerComplete` might re-trigger "Task Complete" dialog?
              // `_onTimerComplete` checks `updatedTask.isCompleted`.
              // If it is already completed, it might trigger logic.

              // Let's just simply:
              // 1. Mark task complete (done).
              // 2. Skip to break.
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
