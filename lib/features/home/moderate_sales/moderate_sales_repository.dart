import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class ModerateSalesRepository {
  Future<List<SaleModel>> getFirst();

  Future<List<SaleModel>> getNext();

  Future<void> moderateSale(SaleModel sale, bool isAccepted);

  bool get hasReachedMax;
}
