import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart' as di;
import '../../data/datasources/admin_remote_data_source.dart';

class AdminProvider with ChangeNotifier {
  final AdminRemoteDataSource remoteDataSource =
      AdminRemoteDataSource(dioClient: di.sl());

  bool _isLoading = false;
  String? _error;

  List<dynamic> _users = [];
  int _totalUsers = 0;
  int _currentPage = 1;

  Map<String, dynamic> _revenueStats = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get users => _users;
  int get totalUsers => _totalUsers;
  int get currentPage => _currentPage;
  Map<String, dynamic> get revenueStats => _revenueStats;

  Future<void> fetchUsers({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await remoteDataSource.getUsers(page: page);
      if (response['success'] == true) {
        _users = response['data'] ?? [];
        _totalUsers = response['pagination']?['total'] ??
            response['total'] ??
            _users.length;
        _currentPage = page;
      } else {
        _error = response['message'] ?? 'Failed to load users';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleProStatus(String userId, bool makePro) async {
    try {
      final response =
          await remoteDataSource.overrideUserSubscription(userId, makePro);
      if (response['success'] == true) {
        final userIndex =
            _users.indexWhere((u) => u['id'] == userId || u['_id'] == userId);
        if (userIndex != -1) {
          _users[userIndex]['isPremium'] = makePro;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to override PRO status: $e';
      notifyListeners();
      return false;
    }
  }

  List<dynamic> _discountCodes = [];
  List<dynamic> get discountCodes => _discountCodes;

  Future<void> fetchRevenueStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await remoteDataSource.getRevenueStats();
      if (response['success'] == true) {
        _revenueStats = response['data'] ?? {};
      }
    } catch (e) {
      debugPrint('Revenue stats fetch error (might be stubbed): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDiscountCodes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await remoteDataSource.getDiscountCodes();
      if (response['success'] == true) {
        _discountCodes = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Discount codes fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDiscountCode(String code, num value, String type,
      {int? maxUses}) async {
    try {
      final data = {
        'code': code.toUpperCase(),
        'value': value,
        'type': type, // 'percentage' or 'fixed'
        if (maxUses != null) 'maxUses': maxUses,
      };
      final response = await remoteDataSource.createDiscountCode(data);
      if (response['success'] == true) {
        await fetchDiscountCodes(); // Refresh
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create code: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDiscountCodeStatus(String id, bool isActive) async {
    try {
      final response = await remoteDataSource.toggleDiscountCode(id, isActive);
      if (response['success'] == true) {
        final index =
            _discountCodes.indexWhere((c) => c['id'] == id || c['_id'] == id);
        if (index != -1) {
          _discountCodes[index]['isActive'] = isActive;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update code status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> bulkUploadQuestions(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await remoteDataSource.bulkImportQuestions(filePath);
      return response['success'] == true;
    } catch (e) {
      _error = 'Bulk upload failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== Moderation Form / Reports ==========
  List<dynamic> _reports = [];
  List<dynamic> get reports => _reports;

  Future<void> fetchReports({int page = 1}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await remoteDataSource.getReports(page: page);
      if (response['success'] == true) {
        _reports = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Reports fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReportStatus(String reportId, String status) async {
    try {
      final response =
          await remoteDataSource.updateReportStatus(reportId, status);
      if (response['success'] == true) {
        final index = _reports
            .indexWhere((c) => c['id'] == reportId || c['_id'] == reportId);
        if (index != -1) {
          _reports[index]['status'] = status;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to action report: $e';
      notifyListeners();
      return false;
    }
  }
}
