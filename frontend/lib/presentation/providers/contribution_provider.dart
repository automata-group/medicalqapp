import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class ContributionProvider extends ChangeNotifier {
  final DioClient dioClient;

  ContributionProvider({required this.dioClient});

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> submitContribution({
    required int specialtyId,
    int? topicId,
    required String questionText,
    List<Map<String, String>>? options,
    String? userAnswer,
    String? notes,
    DateTime? examDate,
    required String confidenceLevel, // 'high', 'medium', 'low'
    String? imagePath,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> payload = {
        'specialtyId': specialtyId,
        'questionText': questionText.trim(),
        'confidenceLevel': confidenceLevel,
      };

      if (topicId != null) payload['topicId'] = topicId;
      if (userAnswer != null && userAnswer.isNotEmpty) payload['userAnswer'] = userAnswer;
      if (notes != null && notes.trim().isNotEmpty) payload['notes'] = notes.trim();
      if (examDate != null) {
        payload['examDate'] = examDate.toIso8601String().split('T').first;
      }
      if (options != null && options.isNotEmpty) {
        payload['options'] = options;
      }

      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        final formMap = Map<String, dynamic>.from(payload);
        formMap['options'] = jsonEncode(options);
        formMap['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(RegExp(r'[/\\]')).last,
        );
        response = await dioClient.post(
          '/contributions',
          data: FormData.fromMap(formMap),
        );
      } else {
        response = await dioClient.post(
          '/contributions',
          data: payload,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _successMessage = response.data?['message'] ??
            'تم استلام مساهمتك بنجاح 🎉 شكرًا لمساعدتك في تطوير SDLE.';
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data?['message'] ?? 'فشل إرسال المساهمة';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ??
          'حدث خطأ في الاتصال بالخادم، يرجى المحاولة لاحقاً';
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
