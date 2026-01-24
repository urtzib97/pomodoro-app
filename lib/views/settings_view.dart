import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../core/ui_ids.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          Text(
            'APARIENCIA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: GetBuilder<SettingsController>(
              id: UiIds.ID_THEME_MODE_SELECTOR,
              builder: (controller) => RadioGroup<ThemeMode>(
                groupValue: controller.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) controller.setThemeMode(value);
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text('Claro'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Oscuro'),
                      value: ThemeMode.dark,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Sistema'),
                      value: ThemeMode.system,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Timer Duration Settings
          Text(
            'DURACIONES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GetBuilder<SettingsController>(
                    id: UiIds.ID_WORK_DURATION_SLIDER,
                    builder: (controller) => _buildSlider(
                      context,
                      label: 'Trabajo',
                      value: controller.workDuration.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      onChanged: (value) =>
                          controller.setWorkDuration(value.toInt()),
                    ),
                  ),
                  const Divider(),
                  GetBuilder<SettingsController>(
                    id: UiIds.ID_SHORT_BREAK_SLIDER,
                    builder: (controller) => _buildSlider(
                      context,
                      label: 'Pausa corta',
                      value: controller.shortBreakDuration.toDouble(),
                      min: 1,
                      max: 15,
                      divisions: 14,
                      onChanged: (value) =>
                          controller.setShortBreakDuration(value.toInt()),
                    ),
                  ),
                  const Divider(),
                  GetBuilder<SettingsController>(
                    id: UiIds.ID_LONG_BREAK_SLIDER,
                    builder: (controller) => _buildSlider(
                      context,
                      label: 'Pausa larga',
                      value: controller.longBreakDuration.toDouble(),
                      min: 10,
                      max: 45,
                      divisions: 35,
                      onChanged: (value) =>
                          controller.setLongBreakDuration(value.toInt()),
                    ),
                  ),
                  const Divider(),
                  GetBuilder<SettingsController>(
                    id: UiIds.ID_POMODOROS_BEFORE_LONG_BREAK_SLIDER,
                    builder: (controller) => _buildSlider(
                      context,
                      label: 'Pomodoros antes de pausa larga',
                      value: controller.pomodorosBeforeLongBreak.toDouble(),
                      min: 2,
                      max: 8,
                      divisions: 6,
                      onChanged: (value) =>
                          controller.setPomodorosBeforeLongBreak(value.toInt()),
                      showMinutes: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sound & Notifications
          Text(
            'SONIDO Y NOTIFICACIONES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                GetBuilder<SettingsController>(
                  id: UiIds.ID_SOUND_SWITCH,
                  builder: (controller) => SwitchListTile(
                    title: const Text('Sonido de notificación'),
                    value: controller.soundEnabled,
                    onChanged: (_) => controller.toggleSound(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Behavior Settings
          Text(
            'COMPORTAMIENTO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                GetBuilder<SettingsController>(
                  id: UiIds.ID_AUTO_START_BREAKS_SWITCH,
                  builder: (controller) => SwitchListTile(
                    title: const Text('Iniciar pausas automáticamente'),
                    subtitle: const Text(
                      'Iniciar el temporizador de pausa al terminar trabajo',
                    ),
                    value: controller.autoStartBreaks,
                    onChanged: (_) => controller.toggleAutoStartBreaks(),
                  ),
                ),
                const Divider(height: 1),
                GetBuilder<SettingsController>(
                  id: UiIds.ID_AUTO_START_POMODOROS_SWITCH,
                  builder: (controller) => SwitchListTile(
                    title: const Text('Iniciar pomodoros automáticamente'),
                    subtitle:
                        const Text('Iniciar el temporizador al terminar pausa'),
                    value: controller.autoStartPomodoros,
                    onChanged: (_) => controller.toggleAutoStartPomodoros(),
                  ),
                ),
                const Divider(height: 1),
                GetBuilder<SettingsController>(
                  id: UiIds.ID_FULLSCREEN_BREAKS_SWITCH,
                  builder: (controller) => SwitchListTile(
                    title: const Text('Pantalla completa en pausas'),
                    subtitle:
                        const Text('Mostrar notificación a pantalla completa'),
                    value: controller.fullscreenBreaks,
                    onChanged: (_) => controller.toggleFullscreenBreaks(),
                  ),
                ),
                const Divider(height: 1),

                // Task Completion Behavior
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Al completar una tarea:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      GetBuilder<SettingsController>(
                        id: UiIds.ID_TASK_COMPLETION_BEHAVIOR_SELECTOR,
                        builder: (controller) => RadioGroup<String>(
                          groupValue: controller.taskCompletionBehavior,
                          onChanged: (v) {
                            if (v != null) {
                              controller.setTaskCompletionBehavior(v);
                            }
                          },
                          child: const Column(
                            children: [
                              RadioListTile<String>(
                                title: Text('Siguiente tarea (Auto)'),
                                value: 'auto',
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<String>(
                                title: Text('Preguntar qué hacer'),
                                value: 'ask',
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<String>(
                                title: Text('Continuar sin tarea'),
                                value: 'continue',
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showResetDialog(context, settingsController),
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar valores predeterminados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    bool showMinutes = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              showMinutes ? '${value.toInt()} min' : '${value.toInt()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restaurar todos los valores a sus valores predeterminados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.resetToDefaults();
              Navigator.of(context).pop();
              Get.snackbar(
                'Configuración restaurada',
                'Todos los valores han sido restaurados',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
