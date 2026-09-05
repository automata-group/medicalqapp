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
  });

  final int? specialtyId;
  final int? achievementId;

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

  const MockExamSectionModel({
    required this.id,
    required this.title,
    required this.questionCount,
  });

  factory MockExamSectionModel.fromJson(Map<String, dynamic> json) {
    return MockExamSectionModel(
      id: json['id'],
      title: json['title'],
      questionCount: json['questionCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, title, questionCount];
}
