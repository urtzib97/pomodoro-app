import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ui_ids.dart';

class SettingsController extends GetxController {
  // Theme
  ThemeMode themeMode = ThemeMode.system;

  // Timer durations (in minutes)
  int workDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 20;

  // Pomodoros before long break
  int pomodorosBeforeLongBreak = 4;

  // Sound settings
  bool soundEnabled = true;
  String selectedSound = 'default';

  // Fullscreen settings
  bool fullscreenBreaks = false;

  // Auto-start next timer
  bool autoStartBreaks = false;
  bool autoStartPomodoros = false;

  // Task Completion Behavior
  String taskCompletionBehavior = 'ask'; // 'ask', 'auto', 'continue'

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final themeModeStr = prefs.getString('themeMode') ?? 'system';
    themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeStr',
      orElse: () => ThemeMode.system,
    );

    // Durations
    workDuration = prefs.getInt('workDuration') ?? 25;
    shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
    longBreakDuration = prefs.getInt('longBreakDuration') ?? 20;
    pomodorosBeforeLongBreak = prefs.getInt('pomodorosBeforeLongBreak') ?? 4;

    // Sound
    soundEnabled = prefs.getBool('soundEnabled') ?? true;
    selectedSound = prefs.getString('selectedSound') ?? 'default';

    // Fullscreen
    fullscreenBreaks = prefs.getBool('fullscreenBreaks') ?? false;

    // Auto-start
    autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;

    // Task Behavior
    taskCompletionBehavior = prefs.getString('taskCompletionBehavior') ?? 'ask';

    update(); // Update all IDs
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'themeMode',
      themeMode.toString().split('.').last,
    );
    await prefs.setInt('workDuration', workDuration);
    await prefs.setInt('shortBreakDuration', shortBreakDuration);
    await prefs.setInt('longBreakDuration', longBreakDuration);
    await prefs.setInt(
      'pomodorosBeforeLongBreak',
      pomodorosBeforeLongBreak,
    );
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setString('selectedSound', selectedSound);
    await prefs.setBool('fullscreenBreaks', fullscreenBreaks);
    await prefs.setBool('autoStartBreaks', autoStartBreaks);
    await prefs.setBool('autoStartPomodoros', autoStartPomodoros);
    await prefs.setString(
      'taskCompletionBehavior',
      taskCompletionBehavior,
    );
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    saveSettings();
    update([UiIds.ID_THEME_MODE_SELECTOR]);
    Get.changeThemeMode(mode);
  }

  void setWorkDuration(int minutes) {
    if (workDuration == minutes) return;
    workDuration = minutes;
    saveSettings();
    update([UiIds.ID_WORK_DURATION_SLIDER]);
  }

  void setShortBreakDuration(int minutes) {
    if (shortBreakDuration == minutes) return;
    shortBreakDuration = minutes;
    saveSettings();
    update([UiIds.ID_SHORT_BREAK_SLIDER]);
  }

  void setLongBreakDuration(int minutes) {
    if (longBreakDuration == minutes) return;
    longBreakDuration = minutes;
    saveSettings();
    update([UiIds.ID_LONG_BREAK_SLIDER]);
  }

  void setPomodorosBeforeLongBreak(int count) {
    if (pomodorosBeforeLongBreak == count) return;
    pomodorosBeforeLongBreak = count;
    saveSettings();
    update([UiIds.ID_POMODOROS_BEFORE_LONG_BREAK_SLIDER]);
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
    saveSettings();
    update([UiIds.ID_SOUND_SWITCH]);
  }

  void setSound(String sound) {
    if (selectedSound == sound) return;
    selectedSound = sound;
    saveSettings();
    // No specific UI ID for sound selection yet, or maybe generic update if needed
    // Assuming UI updates via other means or we add ID later if we add sound selector
  }

  void toggleFullscreenBreaks() {
    fullscreenBreaks = !fullscreenBreaks;
    saveSettings();
    update([UiIds.ID_FULLSCREEN_BREAKS_SWITCH]);
  }

  void toggleAutoStartBreaks() {
    autoStartBreaks = !autoStartBreaks;
    saveSettings();
    update([UiIds.ID_AUTO_START_BREAKS_SWITCH]);
  }

  void toggleAutoStartPomodoros() {
    autoStartPomodoros = !autoStartPomodoros;
    saveSettings();
    update([UiIds.ID_AUTO_START_POMODOROS_SWITCH]);
  }

  void setTaskCompletionBehavior(String behavior) {
    if (taskCompletionBehavior == behavior) return;
    taskCompletionBehavior = behavior;
    saveSettings();
    update([UiIds.ID_TASK_COMPLETION_BEHAVIOR_SELECTOR]);
  }

  void resetToDefaults() {
    workDuration = 25;
    shortBreakDuration = 5;
    longBreakDuration = 20;
    pomodorosBeforeLongBreak = 4;
    soundEnabled = true;
    selectedSound = 'default';
    fullscreenBreaks = false;
    autoStartBreaks = false;
    autoStartPomodoros = false;
    themeMode = ThemeMode.system;
    taskCompletionBehavior = 'ask';
    saveSettings();
    update(); // Update all to reflect reset
    Get.changeThemeMode(ThemeMode.system);
  }
}
