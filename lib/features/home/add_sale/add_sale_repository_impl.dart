import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_remote_datasource.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_repository.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

import '../add_item/item_model.dart';

class AddSaleRepositoryImpl implements AddSaleRepository {
  final AddSaleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddSaleRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> add(SaleModel sale) async {
    await remoteDataSource.add(sale);
  }

  @override
  Future<int> getPhoneBonus(String article) async {
    return await remoteDataSource.getPhoneBonus(article);
  }

  @override
  Future<ItemModel?> getPhoneByImei(String imei) async {
    return await remoteDataSource.getPhoneByImei(imei);
  }
}
