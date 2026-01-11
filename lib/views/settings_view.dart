import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Obx(() => Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  value: ThemeMode.light,
                  groupValue: settingsController.themeMode.value,
                  onChanged: (value) => settingsController.setThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Oscuro'),
                  value: ThemeMode.dark,
                  groupValue: settingsController.themeMode.value,
                  onChanged: (value) => settingsController.setThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Sistema'),
                  value: ThemeMode.system,
                  groupValue: settingsController.themeMode.value,
                  onChanged: (value) => settingsController.setThemeMode(value!),
                ),
              ],
            )),
          ),

          const SizedBox(height: 24),

          // Timer Duration Settings
          Text(
            'DURACIONES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Obx(() => _buildSlider(
                    context,
                    label: 'Trabajo',
                    value: settingsController.workDuration.value.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (value) => settingsController.setWorkDuration(value.toInt()),
                  )),
                  const Divider(),
                  Obx(() => _buildSlider(
                    context,
                    label: 'Pausa corta',
                    value: settingsController.shortBreakDuration.value.toDouble(),
                    min: 1,
                    max: 15,
                    divisions: 14,
                    onChanged: (value) => settingsController.setShortBreakDuration(value.toInt()),
                  )),
                  const Divider(),
                  Obx(() => _buildSlider(
                    context,
                    label: 'Pausa larga',
                    value: settingsController.longBreakDuration.value.toDouble(),
                    min: 10,
                    max: 45,
                    divisions: 35,
                    onChanged: (value) => settingsController.setLongBreakDuration(value.toInt()),
                  )),
                  const Divider(),
                  Obx(() => _buildSlider(
                    context,
                    label: 'Pomodoros antes de pausa larga',
                    value: settingsController.pomodorosBeforeLongBreak.value.toDouble(),
                    min: 2,
                    max: 8,
                    divisions: 6,
                    onChanged: (value) => settingsController.setPomodorosBeforeLongBreak(value.toInt()),
                    showMinutes: false,
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Sound & Notifications
          Text(
            'SONIDO Y NOTIFICACIONES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  title: const Text('Sonido de notificación'),
                  value: settingsController.soundEnabled.value,
                  onChanged: (_) => settingsController.toggleSound(),
                )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Behavior Settings
          Text(
            'COMPORTAMIENTO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  title: const Text('Iniciar pausas automáticamente'),
                  subtitle: const Text('Iniciar el temporizador de pausa al terminar trabajo'),
                  value: settingsController.autoStartBreaks.value,
                  onChanged: (_) => settingsController.toggleAutoStartBreaks(),
                )),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                  title: const Text('Iniciar pomodoros automáticamente'),
                  subtitle: const Text('Iniciar el temporizador al terminar pausa'),
                  value: settingsController.autoStartPomodoros.value,
                  onChanged: (_) => settingsController.toggleAutoStartPomodoros(),
                )),
                const Divider(height: 1),
                Obx(() => SwitchListTile(
                  title: const Text('Pantalla completa en pausas'),
                  subtitle: const Text('Mostrar notificación a pantalla completa'),
                  value: settingsController.fullscreenBreaks.value,
                  onChanged: (_) => settingsController.toggleFullscreenBreaks(),
                )),
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
