import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_remote_datasource.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_repository.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

class AddSaleRepositoryImpl implements AddSaleRepository {
  final AddSaleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddSaleRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> add(SaleModel sale) async {
    await remoteDataSource.add(sale);
  }
}
