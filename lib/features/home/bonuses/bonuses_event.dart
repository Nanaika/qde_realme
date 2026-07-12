abstract class BonusesEvent {}

class BonusesGetEvent extends BonusesEvent {}

class BonusesUpdateEvent extends BonusesEvent {
  final Map<String, String> bonuses;
  BonusesUpdateEvent({required this.bonuses});
}
