import '../../../core/error/failures.dart';

abstract class AddItemsState {}

class AddItemsInitial extends AddItemsState {}

class AddItemsLoading extends AddItemsState {}

class AddItemsSuccess extends AddItemsState {
  final String message;

  AddItemsSuccess({this.message = ''});
}

class AddItemsError extends AddItemsState {
  final Failure failure;

  AddItemsError(this.failure);
}
