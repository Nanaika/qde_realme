class SlaveDataModel {
  final int bonusesSum;
  final int acceptedSum;
  final int declinedSum;
  final int awaitingSum;
  final int paidSum;

  const SlaveDataModel({
    required this.bonusesSum,
    required this.acceptedSum,
    required this.declinedSum,
    required this.awaitingSum,
    required this.paidSum,
  });

  SlaveDataModel copyWith({
    int? bonusesSum,
    int? acceptedSum,
    int? declinedSum,
    int? awaitingSum,
    int? paidSum,
  }) {
    return SlaveDataModel(
      bonusesSum: bonusesSum ?? this.bonusesSum,
      acceptedSum: acceptedSum ?? this.acceptedSum,
      declinedSum: declinedSum ?? this.declinedSum,
      awaitingSum: awaitingSum ?? this.awaitingSum,
      paidSum: paidSum ?? this.paidSum,
    );
  }

  factory SlaveDataModel.fromJson(Map<String, dynamic> json) {
    return SlaveDataModel(
      bonusesSum: json['bonusesSum'] as int? ?? 0,
      acceptedSum: json['acceptedSum'] as int? ?? 0,
      declinedSum: json['declinedSum'] as int? ?? 0,
      awaitingSum: json['awaitingSum'] as int? ?? 0,
      paidSum: json['paidSum'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bonusesSum': bonusesSum,
      'acceptedSum': acceptedSum,
      'declinedSum': declinedSum,
      'awaitingSum': awaitingSum,
      'paidSum': paidSum,
    };
  }
}
