import 'package:equatable/equatable.dart';

class MockExamModel extends Equatable {
  final int id;
  final String title;
  final String? description;
  final int totalQuestions;
  final int duration; // in minutes
  final double price;
  final bool isPremium;
  final List<MockExamSectionModel> sections;

  final int? specialtyId;
  final int? achievementId;
  final int breakDuration;
  final bool hasBreak;
  final String breakScheduleType;
  final int? breakIntervalQuestions;
  final bool allowBreakSkip;

  const MockExamModel({
    required this.id,
    required this.title,
    this.description,
    required this.totalQuestions,
    required this.duration,
    required this.price,
    required this.isPremium,
    this.sections = const [],
    this.specialtyId,
    this.achievementId,
    this.breakDuration = 30,
    this.hasBreak = true,
    this.breakScheduleType = 'between_sections',
    this.breakIntervalQuestions = 50,
    this.allowBreakSkip = true,
  });

  factory MockExamModel.fromJson(Map<String, dynamic> json) {
    return MockExamModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      totalQuestions: json['totalQuestions'] ?? 0,
      duration: json['duration'] ?? 60,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isPremium: json['isPremium'] ?? false,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => MockExamSectionModel.fromJson(e))
              .toList() ??
          [],
      specialtyId: json['specialtyId'],
      achievementId: json['achievementId'],
      breakDuration: json['breakDuration'] ?? 30,
      hasBreak: json['hasBreak'] ?? (json['breakDuration'] != null ? json['breakDuration'] > 0 : true),
      breakScheduleType: json['breakScheduleType'] ?? 'between_sections',
      breakIntervalQuestions: json['breakIntervalQuestions'] ?? 50,
      allowBreakSkip: json['allowBreakSkip'] ?? true,
    );
  }

  MockExamModel copyWith({
    int? id,
    String? title,
    String? description,
    int? totalQuestions,
    int? duration,
    double? price,
    bool? isPremium,
    List<MockExamSectionModel>? sections,
    int? specialtyId,
    int? achievementId,
    int? breakDuration,
    bool? hasBreak,
    String? breakScheduleType,
    int? breakIntervalQuestions,
    bool? allowBreakSkip,
  }) {
    return MockExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isPremium: isPremium ?? this.isPremium,
      sections: sections ?? this.sections,
      specialtyId: specialtyId ?? this.specialtyId,
      achievementId: achievementId ?? this.achievementId,
      breakDuration: breakDuration ?? this.breakDuration,
      hasBreak: hasBreak ?? this.hasBreak,
      breakScheduleType: breakScheduleType ?? this.breakScheduleType,
      breakIntervalQuestions: breakIntervalQuestions ?? this.breakIntervalQuestions,
      allowBreakSkip: allowBreakSkip ?? this.allowBreakSkip,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        totalQuestions,
        duration,
        price,
        isPremium,
        sections,
        specialtyId,
        achievementId,
      ];
}

class MockExamSectionModel extends Equatable {
  final int id;
  final String title;
  final int questionCount;
  final int timeLimit;

  const MockExamSectionModel({
    required this.id,
    required this.title,
    required this.questionCount,
    this.timeLimit = 120,
  });

  factory MockExamSectionModel.fromJson(Map<String, dynamic> json) {
    return MockExamSectionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      questionCount: json['questionCount'] ?? json['totalQuestions'] ?? 0,
      timeLimit: json['timeLimit'] ?? 120,
    );
  }

  @override
  List<Object?> get props => [id, title, questionCount, timeLimit];
}
