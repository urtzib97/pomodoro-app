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
    String path = join(await getDatabasesPath(), 'pomodoro.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tasks table
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

    // Pomodoro sessions table
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

  // Task CRUD operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getActiveTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Pomodoro Session CRUD operations
  Future<int> insertSession(PomodoroSession session) async {
    final db = await database;
    return await db.insert('pomodoro_sessions', session.toMap());
  }

  Future<List<PomodoroSession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_sessions',
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => PomodoroSession.fromMap(maps[i]));
  }

  Future<List<PomodoroSession>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_sessions',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) => PomodoroSession.fromMap(maps[i]));
  }

  Future<int> updateSession(PomodoroSession session) async {
    final db = await database;
    return await db.update(
      'pomodoro_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> getCompletedPomodorosToday() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions
      WHERE completed = 1 
      AND type = 'work'
      AND startTime >= ? 
      AND startTime <= ?
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedPomodorosThisWeek() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions
      WHERE completed = 1 
      AND type = 'work'
      AND startTime >= ?
    ''', [startOfWeekDay.toIso8601String()]);

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
