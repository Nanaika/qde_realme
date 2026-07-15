class ItemModel {
  final String id;
  final String imei1;
  final String imei2;
  final String article;
  final String skuName;

  const ItemModel({
    required this.id,
    required this.imei1,
    required this.imei2,
    required this.article,
    required this.skuName,
  });

  ItemModel copyWith({
    String? id,
    String? imei1,
    String? imei2,
    String? article,
    String? skuName,
  }) {
    return ItemModel(
      id: id ?? this.id,
      imei1: imei1 ?? this.imei1,
      imei2: imei2 ?? this.imei2,
      article: article ?? this.article,
      skuName: skuName ?? this.skuName,
    );
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String? ?? '',
      imei1: json['imei1'] as String? ?? '',
      imei2: json['imei2'] as String? ?? '',
      article: json['article'] as String? ?? '',
      skuName: json['skuName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imei1': imei1,
      'imei2': imei2,
      'article': article,
      'skuName': skuName,
    };
  }
}
