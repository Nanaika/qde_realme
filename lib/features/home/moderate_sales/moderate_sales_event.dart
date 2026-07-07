import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class ModerateSalesEvent {}

class ModerateSalesGetFirstEvent extends ModerateSalesEvent {}
class ModerateSalesGetNextEvent extends ModerateSalesEvent {}
class ModerateSaleEvent extends ModerateSalesEvent {
  final SaleModel sale;
  final bool isAccepted;

  ModerateSaleEvent({this.isAccepted = false, required this.sale});
}
