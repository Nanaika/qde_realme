import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class AddSaleEvent {}

class AddEvent extends AddSaleEvent {
  final SaleModel sale;

  AddEvent(this.sale);
}

class AddSaleResetEvent extends AddSaleEvent {}

class GetPhoneByImeiEvent extends AddSaleEvent {
  final String imei;

  GetPhoneByImeiEvent({required this.imei});
}

class GetPhoneBonusEvent extends AddSaleEvent {
  final String article;

  GetPhoneBonusEvent({required this.article});
}
