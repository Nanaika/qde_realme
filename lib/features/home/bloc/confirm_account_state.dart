import '../../../core/error/failures.dart';

abstract class ConfirmAccountState {}

class ConfirmAccountInitial extends ConfirmAccountState {}

class ConfirmAccountLoading extends ConfirmAccountState {}

class ConfirmAccountSuccess extends ConfirmAccountState {}

class ConfirmAccountError extends ConfirmAccountState {
  final Failure failure;

  ConfirmAccountError(this.failure);
}
