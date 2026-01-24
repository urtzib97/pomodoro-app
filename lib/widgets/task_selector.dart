import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../core/ui_ids.dart';
import '../models/task.dart';

class TaskSelector extends StatelessWidget {
  const TaskSelector({super.key});

  static const _cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
      id: UiIds.ID_CURRENT_TASK_DISPLAY,
      builder: (taskController) {
        final selectedTask = taskController.selectedTask;
        final activeTasks = taskController.activeTasks;

        final cardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        );

        if (activeTasks.isEmpty) {
          return Card(
            shape: cardShape,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No hay tareas activas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          shape: cardShape, // bordes consistentes en las 4 esquinas [web:407]
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarea actual',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButton<Task?>(
                  value: selectedTask,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('Seleccionar tarea'),
                  items: [
                    const DropdownMenuItem<Task?>(
                      value: null,
                      child: Text('Sin tarea'),
                    ),
                    ...activeTasks.map((task) {
                      return DropdownMenuItem<Task?>(
                        value: task,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${task.completedPomodoros}/${task.estimatedPomodoros}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (task) => taskController.selectTask(task),
                ),
                if (selectedTask != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: selectedTask.estimatedPomodoros > 0
                        ? (selectedTask.completedPomodoros /
                            selectedTask.estimatedPomodoros)
                        : 0,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${selectedTask.completedPomodoros} de ${selectedTask.estimatedPomodoros} pomodoros',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
