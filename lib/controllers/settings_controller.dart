import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Theme
  final themeMode = ThemeMode.system.obs;
  
  // Timer durations (in minutes)
  final workDuration = 25.obs;
  final shortBreakDuration = 5.obs;
  final longBreakDuration = 20.obs;
  
  // Pomodoros before long break
  final pomodorosBeforeLongBreak = 4.obs;
  
  // Sound settings
  final soundEnabled = true.obs;
  final selectedSound = 'default'.obs;
  
  // Fullscreen settings
  final fullscreenBreaks = false.obs;
  
  // Auto-start next timer
  final autoStartBreaks = false.obs;
  final autoStartPomodoros = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    final themeModeStr = prefs.getString('themeMode') ?? 'system';
    themeMode.value = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeStr',
      orElse: () => ThemeMode.system,
    );
    
    // Durations
    workDuration.value = prefs.getInt('workDuration') ?? 25;
    shortBreakDuration.value = prefs.getInt('shortBreakDuration') ?? 5;
    longBreakDuration.value = prefs.getInt('longBreakDuration') ?? 20;
    pomodorosBeforeLongBreak.value = prefs.getInt('pomodorosBeforeLongBreak') ?? 4;
    
    // Sound
    soundEnabled.value = prefs.getBool('soundEnabled') ?? true;
    selectedSound.value = prefs.getString('selectedSound') ?? 'default';
    
    // Fullscreen
    fullscreenBreaks.value = prefs.getBool('fullscreenBreaks') ?? false;
    
    // Auto-start
    autoStartBreaks.value = prefs.getBool('autoStartBreaks') ?? false;
    autoStartPomodoros.value = prefs.getBool('autoStartPomodoros') ?? false;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('themeMode', themeMode.value.toString().split('.').last);
    await prefs.setInt('workDuration', workDuration.value);
    await prefs.setInt('shortBreakDuration', shortBreakDuration.value);
    await prefs.setInt('longBreakDuration', longBreakDuration.value);
    await prefs.setInt('pomodorosBeforeLongBreak', pomodorosBeforeLongBreak.value);
    await prefs.setBool('soundEnabled', soundEnabled.value);
    await prefs.setString('selectedSound', selectedSound.value);
    await prefs.setBool('fullscreenBreaks', fullscreenBreaks.value);
    await prefs.setBool('autoStartBreaks', autoStartBreaks.value);
    await prefs.setBool('autoStartPomodoros', autoStartPomodoros.value);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    saveSettings();
  }

  void setWorkDuration(int minutes) {
    workDuration.value = minutes;
    saveSettings();
  }

  void setShortBreakDuration(int minutes) {
    shortBreakDuration.value = minutes;
    saveSettings();
  }

  void setLongBreakDuration(int minutes) {
    longBreakDuration.value = minutes;
    saveSettings();
  }

  void setPomodorosBeforeLongBreak(int count) {
    pomodorosBeforeLongBreak.value = count;
    saveSettings();
  }

  void toggleSound() {
    soundEnabled.value = !soundEnabled.value;
    saveSettings();
  }

  void setSound(String sound) {
    selectedSound.value = sound;
    saveSettings();
  }

  void toggleFullscreenBreaks() {
    fullscreenBreaks.value = !fullscreenBreaks.value;
    saveSettings();
  }

  void toggleAutoStartBreaks() {
    autoStartBreaks.value = !autoStartBreaks.value;
    saveSettings();
  }

  void toggleAutoStartPomodoros() {
    autoStartPomodoros.value = !autoStartPomodoros.value;
    saveSettings();
  }

  void resetToDefaults() {
    workDuration.value = 25;
    shortBreakDuration.value = 5;
    longBreakDuration.value = 20;
    pomodorosBeforeLongBreak.value = 4;
    soundEnabled.value = true;
    selectedSound.value = 'default';
    fullscreenBreaks.value = false;
    autoStartBreaks.value = false;
    autoStartPomodoros.value = false;
    themeMode.value = ThemeMode.system;
    saveSettings();
  }
}
