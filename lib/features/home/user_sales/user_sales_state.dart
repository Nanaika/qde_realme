import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class UserSalesState {}

class UserSalesInitial extends UserSalesState {}

class UserSalesLoading extends UserSalesState {}

class UserSalesSuccess extends UserSalesState {
  final List<SaleModel> data;

  UserSalesSuccess(this.data);
}

class UserSalesError extends UserSalesState {
  final String failure;

  UserSalesError(this.failure);
}
