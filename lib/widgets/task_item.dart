import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar tarea'),
            content:
                Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        taskController.deleteTask(task.id!);
        Get.snackbar(
          'Tarea eliminada',
          task.title,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: InkWell(
          onLongPress: () => _showOptionsBottomSheet(context, taskController),
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) =>
                  taskController.toggleTaskCompletion(context, task.id!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.completedPomodoros}/${task.estimatedPomodoros} pomodoros',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (!task.isCompleted && task.estimatedPomodoros > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: task.completedPomodoros / task.estimatedPomodoros,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                ],
              ],
            ),
            trailing: task.isCompleted
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    TaskController taskController,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar pomodoros estimados'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, taskController);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Eliminar tarea',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, taskController);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TaskController taskController) {
    final controller =
        TextEditingController(text: task.estimatedPomodoros.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar pomodoros'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Estimación',
            helperText: 'Número de pomodoros',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final newEstimate = int.tryParse(controller.text);
              if (newEstimate != null && newEstimate > 0) {
                // We need to implement updateTask method in controller logic or similar
                // But wait, we don't have updateTask exposed publicly except toggle/increment
                // Let's modify directly via db if we can access it OR add method to controller.
                // Controller has _db.
                // Let's see if we can use a clever way.
                // We can use toggleTaskCompletion logic style? No.
                // We should add a method updateTaskEstimate?
                // Or just use the existing private _db reference? No, it's private.
                // Let's assume we can add updateTask in controller in next step or use what we have?
                // Wait, TaskController has `addTask`, `toggleTaskCompletion`, `deleteTask`, `incrementTaskPomodoro`.
                // It does NOT have a generic `updateTask`.
                // I will add `updateTaskEstimate` to `TaskController` via replace_tool first?
                // Or I can add it now.
                // Actually I should have added it in logic phase. My bad.
                // I will update TaskController right after this tool call.
                // For now, I'll allow this code to be written, assuming I will fix TaskController immediately.

                await taskController.updateTaskEstimate(task.id!, newEstimate);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TaskController taskController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              taskController.deleteTask(task.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
