class ItemModel {
  final String id;
  final String imei;

  ItemModel({
    required this.id,
    required this.imei,
  });

  ItemModel copyWith({
    String? id,
    String? imei,
  }) {
    return ItemModel(
      id: id ?? this.id,
      imei: imei ?? this.imei,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String? ?? '',
      imei: json['imei'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imei': imei,
    };
  }

}