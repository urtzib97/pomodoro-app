class PomodoroSession {
  final int? id;
  final int? taskId;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in minutes
  final bool completed;
  final String type; // 'work', 'short_break', 'long_break'

  PomodoroSession({
    this.id,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.completed = false,
    this.type = 'work',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'completed': completed ? 1 : 0,
      'type': type,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      taskId: map['taskId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      duration: map['duration'],
      completed: map['completed'] == 1,
      type: map['type'] ?? 'work',
    );
  }

  PomodoroSession copyWith({
    int? id,
    int? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? completed,
    String? type,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
      type: type ?? this.type,
    );
  }
}
