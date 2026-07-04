import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class AddSaleEvent {}

class AddEvent extends AddSaleEvent {
  final SaleModel sale;
  AddEvent(this.sale);
}