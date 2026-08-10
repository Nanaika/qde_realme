import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class ManageUsersRepository {
  Future<List<UserModel>> get();
  Future<List<SaleModel>> getUserSales(String id);
  Future<void> pay(String userId, String saleId);
}
