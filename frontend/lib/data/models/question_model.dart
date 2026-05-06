import 'package:equatable/equatable.dart';

class QuestionModel extends Equatable {
  final int id;
  final String text;
  final String difficulty;
  final String? specialty;
  final String? topic;
  final String? imageUrl;
  final List<OptionModel> options;
  final bool isBookmarked;
  final bool isPremium;
  final int totalInCategory;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.difficulty,
    this.specialty,
    this.topic,
    this.imageUrl,
    required this.options,
    this.isBookmarked = false,
    this.isPremium = false,
    this.totalInCategory = 0,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      text: json['text'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      specialty: json['specialty']?['name'],
      topic: json['topic']?['name'] ?? json['subTopic'],
      imageUrl: json['image'],
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e))
              .toList() ??
          [],
      isBookmarked: json['isBookmarked'] ?? false,
      isPremium: json['isPremium'] ?? false,
      totalInCategory: json['totalInCategory'] ?? 0,
    );
  }

  QuestionModel copyWith({
    int? id,
    String? text,
    String? difficulty,
    String? specialty,
    String? topic,
    String? imageUrl,
    List<OptionModel>? options,
    bool? isBookmarked,
    bool? isPremium,
    int? totalInCategory,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      difficulty: difficulty ?? this.difficulty,
      specialty: specialty ?? this.specialty,
      topic: topic ?? this.topic,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? this.options,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isPremium: isPremium ?? this.isPremium,
      totalInCategory: totalInCategory ?? this.totalInCategory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        difficulty,
        specialty,
        topic,
        imageUrl,
        options,
        isBookmarked,
        isPremium,
        totalInCategory
      ];
}

class OptionModel extends Equatable {
  final int id;
  final String text;
  final String order;

  const OptionModel({
    required this.id,
    required this.text,
    required this.order,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'],
      text: json['text'] ?? '',
      order: json['order'] as String? ?? '0',
    );
  }

  @override
  @override
  List<Object?> get props => [id, text, order];
}

class QuestionStatsModel extends Equatable {
  final int passRate;
  final int averageTimeSeconds;

  const QuestionStatsModel({
    required this.passRate,
    required this.averageTimeSeconds,
  });

  factory QuestionStatsModel.fromJson(Map<String, dynamic> json) {
    return QuestionStatsModel(
      passRate: (json['passRate'] as num?)?.toInt() ?? 0,
      averageTimeSeconds: (json['averageTimeSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [passRate, averageTimeSeconds];
}

class AnswerResponseModel extends Equatable {
  final bool isCorrect;
  final int correctOptionId;
  final String? explanation;
  final QuestionStatsModel? stats;

  const AnswerResponseModel({
    required this.isCorrect,
    required this.correctOptionId,
    this.explanation,
    this.stats,
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return AnswerResponseModel(
      isCorrect: json['isCorrect'] == true,
      correctOptionId: (json['correctOptionId'] as num?)?.toInt() ?? -1,
      explanation: json['explanation'] is String
          ? json['explanation']
          : (json['explanation'] is Map ? json['explanation']['text'] : null),
      stats: json['stats'] is Map<String, dynamic>
          ? QuestionStatsModel.fromJson(json['stats'])
          : null,
    );
  }

  @override
  List<Object?> get props => [isCorrect, correctOptionId, explanation, stats];
}
