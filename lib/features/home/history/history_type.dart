enum HistoryType {
  imeiPending,
  imeiAccepted,
  imeiDeclined,
  imeiPaid,
  userPending,
  userAccepted,
  userDeclined,
  other;

  static HistoryType fromString(String? value) {
    if (value == null) return HistoryType.other;

    return HistoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HistoryType.other,
    );
  }
}
