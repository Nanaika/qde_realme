import 'package:qde_realme/features/home/add_sale/sale_model.dart';

import '../add_item/item_model.dart';

abstract class AddSaleRepository {
  Future add(SaleModel sale);
  Future<ItemModel?> getPhoneByImei(String imei);
  Future<int> getPhoneBonus(String article);
}
