abstract class UserSalesEvent {}

class GetSalesEvent extends UserSalesEvent {
  final String id;

  GetSalesEvent(this.id);
}

class PaySaleEvent extends UserSalesEvent {
  final String id;
  final String saleId;

  PaySaleEvent(this.id, this.saleId);
}
