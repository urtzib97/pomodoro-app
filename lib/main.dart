import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/ui_ids.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'views/home_view.dart';
import 'controllers/timer_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/stats_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await Get.putAsync(() => DatabaseService().init());

  // Initialize notification service
  await NotificationService.initialize();

  // Initialize controllers
  Get.put(SettingsController());
  Get.put(TaskController());
  Get.put(StatsController());
  Get.put(TimerController());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      id: UiIds.ID_THEME_MODE_SELECTOR,
      builder: (controller) => GetMaterialApp(
        title: 'Pomodoro Timer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: controller.themeMode,
        home: const HomeView(),
      ),
    );
  }
}
