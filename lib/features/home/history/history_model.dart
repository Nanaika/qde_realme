import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String message;
  final String type;
  final DateTime? date;

  HistoryModel({
    required this.message,
    required this.type,
    this.date,
  });

  HistoryModel copyWith({
    String? message,
    String? type,
    DateTime? date,
  }) {
    return HistoryModel(
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      date: json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'date': date != null ? Timestamp.fromDate(date!) : null,
    };
  }
}
