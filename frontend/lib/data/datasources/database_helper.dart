import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web');
    }
    if (_database != null) return _database!;
    _database = await _initDB('mastery_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE local_questions (
  id INTEGER PRIMARY KEY,
  text TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  specialtyId INTEGER NOT NULL,
  specialtyName TEXT,
  topicName TEXT,
  subTopic TEXT,
  image TEXT,
  isPremium INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE local_specialties (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  totalQuestions INTEGER DEFAULT 0,
  isPremium INTEGER NOT NULL DEFAULT 0,
  isDownloaded INTEGER NOT NULL DEFAULT 0
)
''');
    await db.execute('''
CREATE TABLE local_options (
  id INTEGER PRIMARY KEY,
  questionId INTEGER NOT NULL,
  text TEXT NOT NULL,
  isCorrect INTEGER NOT NULL,
  ord TEXT NOT NULL,
  FOREIGN KEY (questionId) REFERENCES local_questions (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE local_explanations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  questionId INTEGER NOT NULL,
  text TEXT NOT NULL,
  FOREIGN KEY (questionId) REFERENCES local_questions (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE local_attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  questionId INTEGER NOT NULL,
  selectedOptionId INTEGER NOT NULL,
  isCorrect INTEGER NOT NULL,
  timeTaken INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  synced INTEGER NOT NULL DEFAULT 0
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE local_questions ADD COLUMN isPremium INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('''
CREATE TABLE local_specialties (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  totalQuestions INTEGER DEFAULT 0,
  isPremium INTEGER NOT NULL DEFAULT 0,
  isDownloaded INTEGER NOT NULL DEFAULT 0
)
''');
    }
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('local_options');
    await db.delete('local_explanations');
    await db.delete('local_questions');
    await db.delete('local_attempts');
    await db.delete('local_specialties');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
