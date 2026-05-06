import 'package:sqflite/sqflite.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../../domain/entities/specialty.dart' as entity;
import 'database_helper.dart';

class QuestionLocalDataSource {
  final DatabaseHelper dbHelper;

  QuestionLocalDataSource({required this.dbHelper});

  Future<void> saveBankLocally(List<dynamic> questionsJson) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      for (var qJson in questionsJson) {
        await txn.insert(
            'local_questions',
            {
              'id': qJson['id'],
              'text': qJson['text'],
              'difficulty': qJson['difficulty'] ?? 'easy',
              'specialtyId': qJson['specialtyId'] ?? 0,
              'specialtyName': qJson['specialty']?['name'],
              'topicName': qJson['topic']?['name'],
              'subTopic': qJson['subTopic'],
              'image': qJson['image'],
              'isPremium': (qJson['isPremium'] == true) ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);

        if (qJson['options'] != null) {
          for (var opt in (qJson['options'] as List<dynamic>)) {
            await txn.insert(
                'local_options',
                {
                  'id': opt['id'],
                  'questionId': qJson['id'],
                  'text': opt['text'],
                  'isCorrect': (opt['isCorrect'] == true) ? 1 : 0,
                  'ord': opt['order'] ?? '0',
                },
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        if (qJson['explanation'] != null) {
          await txn.insert(
              'local_explanations',
              {
                'questionId': qJson['id'],
                'text': qJson['explanation']['text'] ?? '',
              },
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  Future<QuestionModel?> getNextQuestionOffline({
    String? specialtyId,
    String? subTopic,
    String? exclude,
  }) async {
    final db = await dbHelper.database;

    String query = '''
      SELECT q.* 
      FROM local_questions q
      LEFT JOIN local_attempts a ON q.id = a.questionId
      WHERE a.id IS NULL
    ''';
    List<dynamic> args = [];

    if (specialtyId != null) {
      query += ' AND q.specialtyId = ?';
      args.add(int.tryParse(specialtyId) ?? 0);
    }
    if (subTopic != null) {
      query += ' AND (q.subTopic = ? OR q.topicName = ?)';
      args.add(subTopic);
      args.add(subTopic);
    }
    if (exclude != null && exclude.isNotEmpty) {
      query += ' AND q.id NOT IN ($exclude)';
    }

    query += ' LIMIT 1';

    final result = await db.rawQuery(query, args);
    if (result.isEmpty) return null;

    final qRow = result.first;
    final int qId = qRow['id'] as int;

    final optionsResult = await db.query(
      'local_options',
      where: 'questionId = ?',
      whereArgs: [qId],
    );

    final options = optionsResult
        .map((o) => OptionModel(
              id: o['id'] as int,
              text: o['text'] as String,
              order: o['ord'] as String? ?? '0',
            ))
        .toList();

    return QuestionModel(
      id: qId,
      text: qRow['text'] as String,
      difficulty: qRow['difficulty'] as String,
      specialty: qRow['specialtyName'] as String?,
      topic: qRow['topicName'] as String? ?? qRow['subTopic'] as String?,
      imageUrl: qRow['image'] as String?,
      options: options,
      isPremium: (qRow['isPremium'] as int? ?? 0) == 1,
    );
  }

  Future<AnswerResponseModel> submitAnswerOffline(
    int questionId,
    int optionId, {
    int? timeTaken,
  }) async {
    final db = await dbHelper.database;

    final options = await db.query('local_options',
        where: 'questionId = ?', whereArgs: [questionId]);
    final explanationRow = await db.query('local_explanations',
        where: 'questionId = ?', whereArgs: [questionId]);

    int correctOptionId = -1;
    bool isCorrect = false;

    for (var opt in options) {
      if ((opt['isCorrect'] as int) == 1) {
        correctOptionId = opt['id'] as int;
      }
      if ((opt['id'] as int) == optionId && (opt['isCorrect'] as int) == 1) {
        isCorrect = true;
      }
    }

    String? explanationText;
    if (explanationRow.isNotEmpty) {
      explanationText = explanationRow.first['text'] as String?;
    }

    await db.insert('local_attempts', {
      'questionId': questionId,
      'selectedOptionId': optionId,
      'isCorrect': isCorrect ? 1 : 0,
      'timeTaken': timeTaken ?? 0,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });

    return AnswerResponseModel(
      isCorrect: isCorrect,
      correctOptionId: correctOptionId,
      explanation: explanationText,
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAttempts() async {
    final db = await dbHelper.database;
    return await db.query('local_attempts', where: 'synced = 0');
  }

  Future<List<Map<String, dynamic>>> getRichUnsyncedAttempts() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        a.id, a.questionId, a.selectedOptionId, a.isCorrect, a.timestamp,
        q.text as questionText, q.difficulty, q.specialtyName, q.image as specialtyIcon
      FROM local_attempts a
      JOIN local_questions q ON a.questionId = q.id
      WHERE a.synced = 0
      ORDER BY a.timestamp DESC
      LIMIT 20
    ''');
  }

  Future<void> markAttemptsSynced(List<int> attemptIds) async {
    if (attemptIds.isEmpty) return;
    final db = await dbHelper.database;
    await db.update(
      'local_attempts',
      {'synced': 1},
      where: 'id IN (${List.filled(attemptIds.length, '?').join(',')})',
      whereArgs: attemptIds,
    );
  }

  Future<SpecialtyTopicsResponse> getSpecialtyTopicsOffline(int specialtyId) async {
    final db = await dbHelper.database;
    
    // Group by topicName or subTopic from the downloaded bank
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(topicName, subTopic, 'General') as name,
        COUNT(*) as totalQuestions,
        SUM(CASE WHEN a.isCorrect = 1 THEN 1 ELSE 0 END) as mastered,
        SUM(CASE WHEN a.isCorrect = 0 THEN 1 ELSE 0 END) as learning
      FROM local_questions q
      LEFT JOIN local_attempts a ON q.id = a.questionId
      WHERE q.specialtyId = ?
      GROUP BY COALESCE(topicName, subTopic, 'General')
    ''', [specialtyId]);

    final topics = result.map((row) {
      return TopicModel(
        name: row['name'] as String,
        totalQuestions: row['totalQuestions'] as int? ?? 0,
        mastered: row['mastered'] as int? ?? 0,
        learning: row['learning'] as int? ?? 0,
        isNew: 0,
        isLocked: false,     // Allow all downloaded offline
        isPremium: false,    // or check q.isPremium
      );
    }).toList();

    return SpecialtyTopicsResponse(
      topics: topics,
      quotaExceeded: false,
      totalAttempted: 0,
    );
  }

  // --- Specialty Methods ---

  Future<void> saveSpecialtieslocally(List<entity.Specialty> specialties) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      for (var s in specialties) {
        await txn.insert(
          'local_specialties',
          {
            'id': s.id,
            'name': s.name,
            'icon': s.icon,
            'totalQuestions': s.totalQuestions,
            'isPremium': s.isPremium ? 1 : 0,
            // 'isDownloaded' is preserved unless explicitly changed
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        // Update name/icon if exists but don't overwrite isDownloaded
        await txn.update(
          'local_specialties',
          {
            'name': s.name,
            'icon': s.icon,
            'totalQuestions': s.totalQuestions,
            'isPremium': s.isPremium ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [s.id],
        );
      }
    });
  }

  Future<List<entity.Specialty>> getLocalSpecialties() async {
    final db = await dbHelper.database;
    final result = await db.query('local_specialties');

    return result.map((row) {
      return entity.Specialty(
        id: row['id'] as int,
        name: row['name'] as String,
        icon: row['icon'] as String? ?? '',
        totalQuestions: row['totalQuestions'] as int? ?? 0,
        isPremium: (row['isPremium'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  Future<void> markSpecialtyDownloaded(int specialtyId, bool isDownloaded) async {
    final db = await dbHelper.database;
    await db.update(
      'local_specialties',
      {'isDownloaded': isDownloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [specialtyId],
    );
  }

  Future<bool> isSpecialtyDownloaded(int specialtyId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'local_specialties',
      columns: ['isDownloaded'],
      where: 'id = ?',
      whereArgs: [specialtyId],
    );
    if (result.isEmpty) return false;
    return (result.first['isDownloaded'] as int? ?? 0) == 1;
  }
}
