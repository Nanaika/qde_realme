import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_type.dart';

class SaleModel {
  final String imei;
  final Timestamp? dateAdded;
  final String ownerId;
  final AddSaleType type;
  final String id;

  SaleModel({
    required this.imei,
    required this.ownerId,
    this.type = AddSaleType.onModeration,
    required this.id,
    this.dateAdded,
  });

  SaleModel copyWith({
    String? imei,
    Timestamp? dateAdded,
    String? ownerId,
    AddSaleType? type,
    String? id,
  }) {
    return SaleModel(
      imei: imei ?? this.imei,
      dateAdded: dateAdded ?? this.dateAdded,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      imei: json['imei'] as String,
      dateAdded: json['dateAdded'] as Timestamp,
      ownerId: json['ownerId'] as String,
      id: json['id'] as String,
      type: AddSaleType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => AddSaleType.onModeration,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imei': imei,
      'dateAdded': dateAdded,
      'ownerId': ownerId,
      'type': type.name,
      'id': id,
    };
  }
}
