import 'package:equatable/equatable.dart';

class DashboardOverviewModel extends Equatable {
  final int totalSolved;
  final int totalAvailableQuestions;
  final int accuracy;
  final int currentStreak;
  final int? daysToExam;
  final List<SpecialtyStatModel> weakAreas;
  final List<SpecialtyStatModel> strongAreas;
  final List<ActivityGraphModel> activityGraph;
  final List<SpecialtyStatModel> specialtyStats;
  final List<SpecialtyStatModel> allSpecialties;
  final List<ContinueRevisionModel> continueRevision;
  final String motivationalQuote;

  const DashboardOverviewModel({
    required this.totalSolved,
    required this.totalAvailableQuestions,
    required this.accuracy,
    required this.currentStreak,
    this.daysToExam,
    required this.weakAreas,
    required this.strongAreas,
    required this.activityGraph,
    required this.specialtyStats,
    required this.allSpecialties,
    required this.continueRevision,
    required this.motivationalQuote,
  });

  factory DashboardOverviewModel.fromJson(Map<String, dynamic> json) {
    return DashboardOverviewModel(
      totalSolved: json['totalSolved'] ?? 0,
      totalAvailableQuestions: json['totalAvailableQuestions'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      daysToExam: json['daysToExam'],
      weakAreas: (json['weakAreas'] as List<dynamic>?)
              ?.map((e) => SpecialtyStatModel.fromJson(e))
              .toList() ??
          [],
      strongAreas: (json['strongAreas'] as List<dynamic>?)
              ?.map((e) => SpecialtyStatModel.fromJson(e))
              .toList() ??
          [],
      activityGraph: (json['activityGraph'] as List<dynamic>?)
              ?.map((e) => ActivityGraphModel.fromJson(e))
              .toList() ??
          [],
      specialtyStats: (json['specialtyStats'] as List<dynamic>?)
              ?.map((e) => SpecialtyStatModel.fromJson(e))
              .toList() ??
          [],
      allSpecialties: (json['allSpecialties'] as List<dynamic>?)
              ?.map((e) => SpecialtyStatModel.fromJson({
                    ...e,
                    'total': e['totalQuestions'] ?? 0,
                  }))
              .toList() ??
          [],
      continueRevision: (json['continueRevision'] as List<dynamic>?)
              ?.map((e) => ContinueRevisionModel.fromJson(e))
              .toList() ??
          [],
      motivationalQuote: json['motivationalQuote'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'totalSolved': totalSolved,
        'totalAvailableQuestions': totalAvailableQuestions,
        'accuracy': accuracy,
        'currentStreak': currentStreak,
        'daysToExam': daysToExam,
        'weakAreas': weakAreas.map((e) => e.toJson()).toList(),
        'strongAreas': strongAreas.map((e) => e.toJson()).toList(),
        'activityGraph': activityGraph.map((e) => e.toJson()).toList(),
        'specialtyStats': specialtyStats.map((e) => e.toJson()).toList(),
        'allSpecialties': allSpecialties.map((e) => e.toJson()).toList(),
        'continueRevision': continueRevision.map((e) => e.toJson()).toList(),
        'motivationalQuote': motivationalQuote,
      };

  @override
  List<Object?> get props => [
        totalSolved,
        totalAvailableQuestions,
        accuracy,
        currentStreak,
        daysToExam,
        weakAreas,
        strongAreas,
        activityGraph,
        specialtyStats,
        allSpecialties,
        continueRevision,
        motivationalQuote,
      ];
}

class SpecialtyStatModel extends Equatable {
  final int id;
  final String name;
  final String? icon;
  final int total;
  final int correct;
  final int accuracy;
  final bool isPremium;

  const SpecialtyStatModel({
    required this.id,
    required this.name,
    this.icon,
    required this.total,
    required this.correct,
    required this.accuracy,
    this.isPremium = false,
  });

  factory SpecialtyStatModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyStatModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
      total: json['total'] ?? 0,
      correct: json['correct'] ?? 0,
      accuracy: json['accuracy'] ?? 0,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'total': total,
        'correct': correct,
        'accuracy': accuracy,
        'isPremium': isPremium,
      };

  @override
  List<Object?> get props =>
      [id, name, icon, total, correct, accuracy, isPremium];
}

class ActivityGraphModel extends Equatable {
  final String day;
  final int count;

  const ActivityGraphModel({required this.day, required this.count});

  factory ActivityGraphModel.fromJson(Map<String, dynamic> json) {
    return ActivityGraphModel(
      day: json['day'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'count': count,
      };

  @override
  List<Object?> get props => [day, count];
}

class RecentActivityModel extends Equatable {
  final int id;
  final String questionText;
  final String difficulty;
  final bool isCorrect;
  final String specialtyName;
  final String? specialtyIcon;
  final DateTime createdAt;

  const RecentActivityModel({
    required this.id,
    required this.questionText,
    required this.difficulty,
    required this.isCorrect,
    required this.specialtyName,
    this.specialtyIcon,
    required this.createdAt,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'],
      questionText: json['question']?['text'] ?? 'Unknown Question',
      difficulty: json['question']?['difficulty'] ?? 'Unknown',
      isCorrect: json['isCorrect'] ?? false,
      specialtyName: json['question']?['specialty']?['name'] ?? 'General',
      specialtyIcon: json['question']?['specialty']?['icon'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': {
          'text': questionText,
          'difficulty': difficulty,
          'specialty': {
            'name': specialtyName,
            'icon': specialtyIcon,
          },
        },
        'isCorrect': isCorrect,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        questionText,
        difficulty,
        isCorrect,
        specialtyName,
        specialtyIcon,
        createdAt
      ];
}

class ContinueRevisionModel extends Equatable {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type;
  final int? specialtyId;
  final int? topicId;
  final String? topicName;
  final String? icon;

  const ContinueRevisionModel({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    this.specialtyId,
    this.topicId,
    this.topicName,
    this.icon,
  });

  factory ContinueRevisionModel.fromJson(Map<String, dynamic> json) {
    return ContinueRevisionModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'specialty',
      specialtyId: json['specialtyId'] as int?,
      topicId: json['topicId'] as int?,
      topicName: json['topicName'] as String?,
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'specialtyId': specialtyId,
        'topicId': topicId,
        'topicName': topicName,
        'icon': icon,
      };

  @override
  List<Object?> get props =>
      [title, subtitle, timestamp, type, specialtyId, topicId, topicName, icon];
}
