import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_type.dart';

class SaleModel {
  final String imei;
  final String imei2;
  final String article;
  final String skuName;
  final DateTime? dateAdded;
  final String ownerId;
  final String ownerEmail;
  final String ownerName;
  final String ownerNumber;
  final AddSaleType type;
  final String id;
  final int bonus;

  SaleModel({
    required this.imei,
    this.imei2 = '',
    this.article = '',
    this.skuName = '',
    required this.ownerId,
    this.ownerEmail = '',
    this.ownerName = '',
    this.ownerNumber = '',
    this.type = AddSaleType.onModeration,
    required this.id,
    this.dateAdded,
    required this.bonus,
  });

  SaleModel copyWith({
    String? imei,
    String? imei2,
    String? article,
    String? skuName,
    DateTime? dateAdded,
    String? ownerId,
    String? ownerEmail,
    String? ownerName,
    String? ownerNumber,
    AddSaleType? type,
    String? id,
    int? bonus,
  }) {
    return SaleModel(
      imei: imei ?? this.imei,
      imei2: imei2 ?? this.imei2,
      article: article ?? this.article,
      skuName: skuName ?? this.skuName,
      dateAdded: dateAdded ?? this.dateAdded,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      ownerNumber: ownerNumber ?? this.ownerNumber,
      type: type ?? this.type,
      id: id ?? this.id,
      bonus: bonus ?? this.bonus,
    );
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      imei: json['imei'] as String? ?? '',
      imei2: json['imei2'] as String? ?? '',
      article: json['article'] as String? ?? '',
      skuName: json['skuName'] as String? ?? '',
      dateAdded: json['dateAdded'] != null ? (json['dateAdded'] as Timestamp).toDate() : null,
      ownerId: json['ownerId'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerNumber: json['ownerNumber'] as String? ?? '',
      id: json['id'] as String? ?? '',
      bonus: (json['bonus'] as num?)?.toInt() ?? 0,
      type: AddSaleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddSaleType.onModeration,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imei': imei,
      'imei2': imei2,
      'article': article,
      'skuName': skuName,
      'dateAdded': dateAdded != null ? Timestamp.fromDate(dateAdded!) : null,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'ownerNumber': ownerNumber,
      'type': type.name,
      'id': id,
      'bonus': bonus,
    };
  }
}
