class TopicModel {
  final String name;
  final int totalQuestions;
  final int mastered;
  final int learning;
  final int isNew; // 'new' is a keyword, so using isNew
  final bool isPremium;
  final bool isLocked; // Locked for free users (set by backend)

  TopicModel({
    required this.name,
    required this.totalQuestions,
    required this.mastered,
    required this.learning,
    required this.isNew,
    this.isPremium = false,
    this.isLocked = false,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      name: json['name'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      mastered: json['mastered'] ?? 0,
      learning: json['learning'] ?? 0,
      isNew: json['new'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }
}

class SpecialtyTopicsResponse {
  final List<TopicModel> topics;
  final bool quotaExceeded;
  final int totalAttempted;

  SpecialtyTopicsResponse({
    required this.topics,
    required this.quotaExceeded,
    required this.totalAttempted,
  });

  factory SpecialtyTopicsResponse.fromJson(Map<String, dynamic> json) {
    return SpecialtyTopicsResponse(
      topics: (json['data'] as List<dynamic>?)
              ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quotaExceeded: json['quotaExceeded'] ?? false,
      totalAttempted: json['totalAttempted'] ?? 0,
    );
  }
}
