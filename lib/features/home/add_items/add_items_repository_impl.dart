import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';

import 'add_items_remote_datasource.dart';
import 'add_items_repository.dart';


class AddItemsRepositoryImpl implements AddItemsRepository {
  final AddItemsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AddItemsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> add(List<ItemModel> items) async {
    await remoteDataSource.add(items);
  }
}
