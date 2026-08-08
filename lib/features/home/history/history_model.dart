import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String message;
  final String bonus;
  final String skuName;
  final String type;
  final DateTime? date;

  HistoryModel({
    required this.message,
    this.bonus = '',
    this.skuName = '',
    required this.type,
    this.date,
  });

  HistoryModel copyWith({
    String? message,
    String? bonus,
    String? skuName,
    String? type,
    DateTime? date,
  }) {
    return HistoryModel(
      message: message ?? this.message,
      bonus: bonus ?? this.bonus,
      skuName: skuName ?? this.skuName,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      message: json['message'] as String? ?? '',
      bonus: json['bonus'] as String? ?? '',
      skuName: json['skuName'] as String? ?? '',
      type: json['type'] as String? ?? '',
      date: json['date'] != null ? (json['date'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bonus': bonus,
      'skuName': skuName,
      'type': type,
      'date': date != null ? Timestamp.fromDate(date!) : null,
    };
  }
}
