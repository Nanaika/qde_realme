import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class AddSaleRepository {
  Future add(SaleModel sale);
}
