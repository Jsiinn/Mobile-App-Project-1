import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_quest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        unit_preference TEXT NOT NULL DEFAULT 'kg',
        created_at TEXT NOT NULL
      )
    ''');

    // Exercises table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        equipment TEXT,
        notes TEXT
      )
    ''');

    // Workouts table
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Workout sets table
    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        goal_value INTEGER NOT NULL,
        current_value INTEGER NOT NULL DEFAULT 0,
        is_complete INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE milestones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        achieved_at TEXT,
        is_achieved INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE personal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        achieved_at TEXT NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');
  }


  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }

  Future<List<Map<String, dynamic>>> getAllExercises() async {
    final db = await database;
    return await db.query('exercises', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> searchExercises(String query) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'name LIKE ? OR muscle_group LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  Future<int> updateExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [exercise['id']],
    );
  }

  Future<int> deleteExercise(int id) async {
    final db = await database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }


  Future<int> insertWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('workouts', workout);
  }

  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final db = await database;
    return await db.query('workouts', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getRecentWorkouts(int limit) async {
    final db = await database;
    return await db.query('workouts', orderBy: 'date DESC', limit: limit);
  }


  Future<int> insertWorkoutSet(Map<String, dynamic> workoutSet) async {
    final db = await database;
    return await db.insert('workout_sets', workoutSet);
  }

  Future<List<Map<String, dynamic>>> getSetsForWorkout(int workoutId) async {
    final db = await database;
    return await db.query(
      'workout_sets',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<int> deleteWorkoutSet(int id) async {
    final db = await database;
    return await db.delete('workout_sets', where: 'id = ?', whereArgs: [id]);
  }


  Future<int> insertPersonalRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('personal_records', record);
  }

  Future<List<Map<String, dynamic>>> getPersonalRecords() async {
    final db = await database;
    return await db.query('personal_records', orderBy: 'achieved_at DESC');
  }

  Future<List<Map<String, dynamic>>> getRecordsForExercise(int exerciseId) async {
    final db = await database;
    return await db.query(
      'personal_records',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'weight DESC',
    );
  }


  Future<int> insertQuest(Map<String, dynamic> quest) async {
    final db = await database;
    return await db.insert('quests', quest);
  }

  Future<List<Map<String, dynamic>>> getAllQuests() async {
    final db = await database;
    return await db.query('quests');
  }

  Future<int> updateQuest(Map<String, dynamic> quest) async {
    final db = await database;
    return await db.update(
      'quests',
      quest,
      where: 'id = ?',
      whereArgs: [quest['id']],
    );
  }


  Future close() async {
    final db = await database;
    db.close();
  }
}