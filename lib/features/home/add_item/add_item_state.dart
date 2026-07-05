import '../../../core/error/failures.dart';

abstract class AddItemState {}

class AddItemInitial extends AddItemState {}

class AddItemLoading extends AddItemState {}

class AddItemSuccess extends AddItemState {}

class AddItemError extends AddItemState {
  final Failure failure;

  AddItemError(this.failure);
}