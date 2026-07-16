import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final Timestamp? date;
  final String id;
  final String imei1;
  final String imei2;
  final String article;
  final String skuName;

  const ItemModel({
    this.date,
    required this.id,
    required this.imei1,
    required this.imei2,
    required this.article,
    required this.skuName,
  });

  ItemModel copyWith({
    Timestamp? date,
    String? id,
    String? imei1,
    String? imei2,
    String? article,
    String? skuName,
  }) {
    return ItemModel(
      date: date ?? this.date,
      id: id ?? this.id,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      article: article ?? this.article,
      skuName: skuName ?? this.skuName,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      date: json['date'] as Timestamp?,
      id: json['id'] as String? ?? '',
      imei1: json['imei1'] as String? ?? '',
      imei2: json['imei2'] as String? ?? '',
      article: json['article'] as String? ?? '',
      skuName: json['skuName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'id': id,
      'imei1': imei1,
      'imei2': imei2,
      'article': article,
      'skuName': skuName,
    };
  }
}
