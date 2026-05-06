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
    return UserModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? json['fullName'] ?? 'User',
      email: json['email'] ?? '',
      hasSpecialties: json['hasSpecialties'] ?? false,
      hasStudyPlan: json['hasStudyPlan'] ?? false,
      isPremium: json['isPremium'] ?? false,
      referralCode: json['referralCode'],
      role: json['role'] ?? 'user',
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
