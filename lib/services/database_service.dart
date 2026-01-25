import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';

class DatabaseService extends GetxService {
  static Database? _database;

  Future<DatabaseService> init() async {
    await _initDatabase();
    return this;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'pomodoro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        estimatedPomodoros INTEGER NOT NULL,
        completedPomodoros INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        startTime TEXT NOT NULL,
        endTime TEXT,
        duration INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        type TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE SET NULL
      )
    ''');
  }

  // Task CRUD
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getActiveTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Session CRUD
  Future<int> insertSession(PomodoroSession session) async {
    final db = await database;
    return await db.insert('pomodoro_sessions', session.toMap());
  }

  Future<List<PomodoroSession>> getAllSessions() async {
    final db = await database;
    final maps = await db.query('pomodoro_sessions', orderBy: 'startTime DESC');
    return List.generate(maps.length, (i) => PomodoroSession.fromMap(maps[i]));
  }

  /// Uses a half-open range: [startInclusive, endExclusive).
  Future<List<PomodoroSession>> getSessionsByDateRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final db = await database;
    final maps = await db.query(
      'pomodoro_sessions',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [
        startInclusive.toIso8601String(),
        endExclusive.toIso8601String()
      ],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => PomodoroSession.fromMap(maps[i]));
  }

  Future<int> updateSession(PomodoroSession session) async {
    final db = await database;
    return await db.update('pomodoro_sessions', session.toMap(),
        where: 'id = ?', whereArgs: [session.id]);
  }

  /// Weekly breakdown: count completed work sessions per calendar day.
  ///
  /// Note: Comparing ISO-8601 timestamps stored as TEXT works lexicographically
  /// for chronological order as long as you store timestamps consistently
  /// (all local or all UTC, and same ISO format). [web:688]
  Future<Map<DateTime, int>> getCompletedWorkSessionsCountByDay(
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT substr(startTime, 1, 10) as dayKey, COUNT(*) as count
      FROM pomodoro_sessions
      WHERE completed = 1 AND type = 'work'
        AND startTime >= ? AND startTime < ?
      GROUP BY dayKey
      ORDER BY dayKey ASC
      ''',
      [startInclusive.toIso8601String(), endExclusive.toIso8601String()],
    );

    final map = <DateTime, int>{};

    for (final row in result) {
      final dayKey = row['dayKey'] as String?;
      if (dayKey == null || dayKey.length != 10)
        continue; // defensive: 'YYYY-MM-DD'

      final count = (row['count'] as num?)?.toInt() ?? 0;

      final parts = dayKey.split('-');
      if (parts.length != 3) continue;

      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) continue;

      final day = DateUtils.dateOnly(DateTime(y, m, d));
      map[day] = count;
    }

    return map;
  }

  /// Aggregated stats for work sessions in [startInclusive, endExclusive).
  /// Returns:
  /// - totalCount: total work sessions (completed + not completed)
  /// - completedCount: completed work sessions
  /// - totalMinutes: sum(duration) for completed work sessions
  Future<Map<String, int>> getWorkSessionStatsByRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as totalCount,
        SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completedCount,
        SUM(CASE WHEN completed = 1 THEN duration ELSE 0 END) as totalMinutes
      FROM pomodoro_sessions
      WHERE type = 'work'
        AND startTime >= ? AND startTime < ?
      ''',
      [startInclusive.toIso8601String(), endExclusive.toIso8601String()],
    );

    final row = result.isNotEmpty ? result.first : const <String, Object?>{};

    return {
      'totalCount': (row['totalCount'] as num?)?.toInt() ?? 0,
      'completedCount': (row['completedCount'] as num?)?.toInt() ?? 0,
      'totalMinutes': (row['totalMinutes'] as num?)?.toInt() ?? 0,
    };
  }
}
