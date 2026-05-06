import 'package:equatable/equatable.dart';

class AchievementModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final int progress;
  final int target;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.isUnlocked,
    required this.progress,
    required this.target,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      xpReward: json['xpReward'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      progress: json['progress'] ?? 0,
      target: json['target'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        xpReward,
        isUnlocked,
        progress,
        target,
      ];
}
