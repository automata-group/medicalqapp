import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final int id;
  final String? specialtyId;
  final String? subTopic;
  final String? filter;
  final List<int> attemptedIds;
  final int? lastQuestionId;

  final String? sessionType;
  final int correctCount;
  
  const SessionModel({
    required this.id,
    this.specialtyId,
    this.subTopic,
    this.filter,
    required this.attemptedIds,
    this.lastQuestionId,
    this.sessionType,
    this.correctCount = 0,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      specialtyId: json['specialtyId']?.toString(),
      subTopic: json['subTopic'],
      filter: json['filter'],
      attemptedIds: List<int>.from(json['attemptedIds'] ?? []),
      lastQuestionId: json['lastQuestionId'],
      sessionType: json['sessionType'],
      correctCount: json['correctCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'specialtyId': specialtyId,
        'subTopic': subTopic,
        'filter': filter,
        'attemptedIds': attemptedIds,
        'lastQuestionId': lastQuestionId,
        'sessionType': sessionType,
        'correctCount': correctCount,
      };

  @override
  List<Object?> get props =>
      [id, specialtyId, subTopic, filter, attemptedIds, lastQuestionId, sessionType, correctCount];
}
