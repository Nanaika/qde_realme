import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';

import 'add_item_remote_datasource.dart';
import 'add_item_repository.dart';

class AddItemRepositoryImpl implements AddItemRepository {
  final AddItemRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddItemRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> add(ItemModel item) async {
    await remoteDataSource.add(item);
  }
}
