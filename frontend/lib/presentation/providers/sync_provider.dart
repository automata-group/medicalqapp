import 'package:flutter/material.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/datasources/question_local_data_source.dart';
import '../../core/network/dio_client.dart';

enum SyncStatus { idle, downloading, uploading, success, error }

class SyncProvider extends ChangeNotifier {
  final DioClient dioClient;
  final QuestionLocalDataSource localDataSource;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  String _message = '';
  String get message => _message;

  int _pendingAttempts = 0;
  int get pendingAttempts => _pendingAttempts;

  bool _isDownloaded = false;
  bool get isDownloaded => _isDownloaded;

  VoidCallback? onSyncComplete;

  SyncProvider({required this.dioClient, required this.localDataSource});

  Future<void> downloadSpecialtyBank(int specialtyId) async {
    _status = SyncStatus.downloading;
    _message = 'Downloading question bank...';
    notifyListeners();

    try {
      final response = await dioClient.get(
        '/offline/download-questions',
        queryParameters: {'specialtyId': specialtyId},
      );

      if (response.data['success'] == true) {
        final List<dynamic> questionsJson = response.data['data'];
        await localDataSource.saveBankLocally(questionsJson);
        await localDataSource.markSpecialtyDownloaded(specialtyId, true);
        _isDownloaded = true;
        _status = SyncStatus.success;
        _message = 'Downloaded ${questionsJson.length} questions successfully!';
      } else {
        throw Exception('Server returned failure');
      }
    } catch (e) {
      _status = SyncStatus.error;
      _message = 'Download failed: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> syncPendingAttempts() async {
    await refreshPendingCount(); // Ensure latest count is loaded
    
    _status = SyncStatus.uploading;
    _message = 'Syncing your offline answers...';
    notifyListeners();

    try {
      final attempts = await localDataSource.getUnsyncedAttempts();
      if (attempts.isEmpty) {
        _status = SyncStatus.idle;
        _message = 'Nothing to sync.';
        notifyListeners();
        return;
      }

      final response = await dioClient.post('/offline/sync', data: {
        'attempts': attempts
            .map((a) => {
                  'questionId': a['questionId'],
                  'selectedOptionId': a['selectedOptionId'],
                  'isCorrect': a['isCorrect'] == 1,
                  'timeTaken': a['timeTaken'],
                  'timestamp': a['timestamp'],
                })
            .toList(),
      });

      if (response.data['success'] == true) {
        final attemptIds = attempts.map<int>((a) => a['id'] as int).toList();
        await localDataSource.markAttemptsSynced(attemptIds);
        _pendingAttempts = 0;
        _status = SyncStatus.success;
        _message = 'Synced ${attempts.length} offline answers!';
        onSyncComplete?.call();
      } else {
        throw Exception('Sync failed on server');
      }
    } catch (e) {
      _status = SyncStatus.error;
      _message = 'Sync failed: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> refreshPendingCount() async {
    final attempts = await localDataSource.getUnsyncedAttempts();
    _pendingAttempts = attempts.length;
    notifyListeners();
  }

  Future<void> clearLocalDatabase() async {
    await DatabaseHelper.instance.clearDatabase();
    _isDownloaded = false;
    _pendingAttempts = 0;
    _message = 'Local data cleared.';
    notifyListeners();
  }
}
