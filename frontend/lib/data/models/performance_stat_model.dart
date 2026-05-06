import 'package:equatable/equatable.dart';

class PerformanceStatModel extends Equatable {
  final DateTime date;
  final int total;
  final int correct;

  const PerformanceStatModel({
    required this.date,
    required this.total,
    required this.correct,
  });

  factory PerformanceStatModel.fromJson(Map<String, dynamic> json) {
    return PerformanceStatModel(
      date: DateTime.parse(json['date']),
      total: json['total'] is int
          ? json['total']
          : int.parse(json['total'].toString()),
      correct: json['correct'] is int
          ? json['correct']
          : int.parse(json['correct'].toString()),
    );
  }

  @override
  List<Object?> get props => [date, total, correct];
}
