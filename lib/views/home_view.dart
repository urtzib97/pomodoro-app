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
    final taskController = Get.find<TaskController>();

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
                      Obx(() => Text(
                        timerController.currentPhaseLabel,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _getPhaseColor(context, timerController),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                      
                      const SizedBox(height: 40),
                      
                      // Circular Timer
                      const CircularTimer(),
                      
                      const SizedBox(height: 40),
                      
                      // Pomodoro Counter
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${timerController.completedPomodoros.value} Pomodoros completados',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      )),
                      
                      const SizedBox(height: 32),
                      
                      // Task Selector
                      const TaskSelector(),
                      
                      const SizedBox(height: 32),
                      
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
      bottomNavigationBar: Obx(() {
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
      }),
    );
  }

  Color _getPhaseColor(BuildContext context, TimerController controller) {
    if (controller.timerState.value == TimerState.break_time) {
      return controller.currentBreakType.value == BreakType.long_break
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).colorScheme.primary;
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
