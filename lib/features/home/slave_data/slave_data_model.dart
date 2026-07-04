class SlaveDataModel {
  final int bonusesSum;
  final int acceptedSum;
  final int declinedSum;
  final int awaitingSum;

  const SlaveDataModel({
    required this.bonusesSum,
    required this.acceptedSum,
    required this.declinedSum,
    required this.awaitingSum,
  });

  SlaveDataModel copyWith({
    int? bonusesSum,
    int? acceptedSum,
    int? declinedSum,
    int? awaitingSum,
  }) {
    return SlaveDataModel(
      bonusesSum: bonusesSum ?? this.bonusesSum,
      acceptedSum: acceptedSum ?? this.acceptedSum,
      declinedSum: declinedSum ?? this.declinedSum,
      awaitingSum: awaitingSum ?? this.awaitingSum,
    );
  }

  factory SlaveDataModel.fromJson(Map<String, dynamic> json) {
    return SlaveDataModel(
      bonusesSum: json['bonusesSum'] as int? ?? 0,
      acceptedSum: json['acceptedSum'] as int? ?? 0,
      declinedSum: json['declinedSum'] as int? ?? 0,
      awaitingSum: json['awaitingSum'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bonusesSum': bonusesSum,
      'acceptedSum': acceptedSum,
      'declinedSum': declinedSum,
      'awaitingSum': awaitingSum,
    };
  }
}