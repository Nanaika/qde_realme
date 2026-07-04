import '../../../core/error/failures.dart';

abstract class AddSaleState {}

class AddSaleInitial extends AddSaleState {}

class AddSaleLoading extends AddSaleState {}

class AddSaleSuccess extends AddSaleState {}

class AddSaleError extends AddSaleState {
  final Failure failure;

  AddSaleError(this.failure);
}