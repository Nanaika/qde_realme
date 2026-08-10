import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

import 'manage_users_remote_datasource.dart';
import 'manage_users_repository.dart';

class ManageUsersRepositoryImpl implements ManageUsersRepository {
  final ManageUsersRemoteDatasource remoteDataSource;
  final NetworkInfo networkInfo;

  ManageUsersRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<List<UserModel>> get() async {
    return await remoteDataSource.get();
  }

  @override
  Future<void> pay(String userId, String saleId) async {
    await remoteDataSource.pay(userId, saleId);
  }

  @override
  Future<List<SaleModel>> getUserSales(String id) async {
    return await remoteDataSource.getUserSales(id);
  }
}
