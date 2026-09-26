import '../../domain/entities/specialty.dart';

class SpecialtyModel extends Specialty {
  const SpecialtyModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.totalQuestions,
    super.percentage,
    super.isPremium,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      totalQuestions: int.tryParse(json['totalQuestions']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isPremium: json['isPremium'] == true || json['isPremium'] == 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'isPremium': isPremium,
    };
  }
}
