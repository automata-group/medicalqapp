import 'package:equatable/equatable.dart';

class Specialty extends Equatable {
  final int id;
  final String name;
  final String icon; // Icon name for MaterialIcons or svg path
  final int totalQuestions;
  final double percentage; // For progress tracking
  final bool isPremium;

  const Specialty({
    required this.id,
    required this.name,
    required this.icon,
    required this.totalQuestions,
    this.percentage = 0.0,
    this.isPremium = false,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'isPremium': isPremium,
      };

  @override
  List<Object?> get props =>
      [id, name, icon, totalQuestions, percentage, isPremium];
}
