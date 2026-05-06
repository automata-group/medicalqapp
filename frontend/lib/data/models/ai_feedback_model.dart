import 'package:equatable/equatable.dart';

class AIFeedbackModel extends Equatable {
  final int id;
  final String content;
  final String analysisType;
  final bool isRead;
  final DateTime expiresAt;
  final DateTime createdAt;

  const AIFeedbackModel({
    required this.id,
    required this.content,
    required this.analysisType,
    required this.isRead,
    required this.expiresAt,
    required this.createdAt,
  });

  factory AIFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AIFeedbackModel(
      id: json['id'],
      content: json['content'],
      analysisType: json['analysisType'] ?? 'mistake_analysis',
      isRead: json['isRead'] ?? false,
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props =>
      [id, content, analysisType, isRead, expiresAt, createdAt];
}
