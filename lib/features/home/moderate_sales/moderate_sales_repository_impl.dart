import 'package:qde_realme/core/network/network_info.dart';

import '../add_sale/sale_model.dart';
import 'moderate_sales_remote_datasource.dart';
import 'moderate_sales_repository.dart';

class ModerateSalesRepositoryImpl implements ModerateSalesRepository {
  final ModerateSalesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ModerateSalesRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  bool hasReachedMax = false;

  @override
  Future<List<SaleModel>> getFirst() async {
    hasReachedMax = false;

    final items = await remoteDataSource.getFirst();

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }

  @override
  Future<List<SaleModel>> getNext() async {
    if (hasReachedMax) return [];

    final items = await remoteDataSource.getNext();

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }

  @override
  Future<void> moderateSale(SaleModel sale, bool isAccepted) async {
    await remoteDataSource.moderateSale(sale, isAccepted);
  }
}
