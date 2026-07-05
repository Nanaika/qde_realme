import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';

abstract class AddItemRemoteDataSource {
  Future add(ItemModel item);
}

class AddItemRemoteDataSourceImpl implements AddItemRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(ItemModel item) async {
    final docRef = db.collection(AppConstants.items).doc();

    final updatedItem = item.copyWith(id: docRef.id);

    await docRef.set(updatedItem.toJson());
  }
}
