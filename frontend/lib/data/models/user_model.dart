class UserModel {
  final String id;
  final String name;
  final String email;

  final bool hasSpecialties;
  final bool hasStudyPlan;
  final bool isPremium;
  final String? referralCode;
  final String role; // Add role for admin checking

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.hasSpecialties = false,
    this.hasStudyPlan = false,
    this.isPremium = false,
    this.referralCode,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final bool hasSpecialties = json['hasSpecialties'] == true ||
        (json['specialties'] is List && (json['specialties'] as List).isNotEmpty);
    final bool hasStudyPlan = json['hasStudyPlan'] == true ||
        (json['studyPlan'] != null && json['studyPlan'] != false);

    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? json['fullName'] ?? 'User',
      email: json['email'] ?? '',
      hasSpecialties: hasSpecialties,
      hasStudyPlan: hasStudyPlan,
      isPremium: json['isPremium'] ?? false,
      referralCode: json['referralCode'],
      role: json['role'] ?? 'user',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? hasSpecialties,
    bool? hasStudyPlan,
    bool? isPremium,
    String? referralCode,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      hasSpecialties: hasSpecialties ?? this.hasSpecialties,
      hasStudyPlan: hasStudyPlan ?? this.hasStudyPlan,
      isPremium: isPremium ?? this.isPremium,
      referralCode: referralCode ?? this.referralCode,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'hasSpecialties': hasSpecialties,
      'hasStudyPlan': hasStudyPlan,
      'isPremium': isPremium,
      'referralCode': referralCode,
      'role': role,
    };
  }
}
