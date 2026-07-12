import '../../../core/error/failures.dart';

abstract class BonusesState {}

class BonusesInitial extends BonusesState {}

class BonusesLoading extends BonusesState {}

class BonusesUpdateSuccess extends BonusesState {}

class BonusesSuccess extends BonusesState {
  final Map<String, String> bonuses;

  BonusesSuccess({required this.bonuses});
}

class BonusesError extends BonusesState {
  final Failure failure;

  BonusesError(this.failure);
}
