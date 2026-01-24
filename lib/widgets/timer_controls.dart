import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timer_controller.dart';
import '../core/ui_ids.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimerController>(
      id: UiIds.ID_TIMER_CONTROLS,
      builder: (timerController) {
        final isRunning = timerController.timerState == TimerState.running;
        final isIdle = timerController.timerState == TimerState.idle;
        final isBreak = timerController.isBreakPhase;

        return Column(
          children: [
            // Main control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Pause button
                _buildMainButton(
                  context,
                  onPressed: isRunning
                      ? () => timerController.pauseTimer()
                      : () => timerController.startTimer(),
                  icon: isRunning ? Icons.pause : Icons.play_arrow,
                  label: isRunning ? 'Pausar' : 'Iniciar',
                  isPrimary: true,
                ),

                const SizedBox(width: 16),

                // Reset button
                if (!isIdle)
                  _buildMainButton(
                    context,
                    onPressed: () => _showResetDialog(context, timerController),
                    icon: Icons.refresh,
                    label: 'Reiniciar',
                    isPrimary: false,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Skip buttons
            if (!isIdle)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: isBreak
                        ? () => timerController.skipBreak()
                        : () => timerController.skipToBreak(),
                    icon: const Icon(Icons.skip_next, size: 20),
                    label:
                        Text(isBreak ? 'Saltar descanso' : 'Saltar descanso'),
                    style: TextButton.styleFrom(
                      // Ensure adequate touch target
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, TimerController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar temporizador'),
        content: const Text(
          '¿Estás seguro de que quieres reiniciar el temporizador? El progreso actual se perderá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              controller.resetTimer();
              Navigator.of(context).pop();
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}
