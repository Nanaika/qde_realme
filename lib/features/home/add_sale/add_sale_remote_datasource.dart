import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';
import 'package:qde_realme/features/home/history/history_model.dart';
import 'package:qde_realme/features/home/history/history_type.dart';

abstract class AddSaleRemoteDataSource {
  Future add(SaleModel sale);

  Future<ItemModel?> getPhoneByImei(String imei);

  Future<int> getPhoneBonus(String article);
}

class AddSaleRemoteDataSourceImpl implements AddSaleRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(SaleModel sale) async {
    final batch = db.batch();

    final refModerate = db.collection(AppConstants.moderateSales).doc();
    final historyRef = db.collection(AppConstants.users).doc(sale.ownerId).collection(AppConstants.history).doc();

    final updatedSale = sale.copyWith(id: refModerate.id);

    final history = HistoryModel(message: updatedSale.imei, type: HistoryType.imeiPending.name);

    final ref = db
        .collection(AppConstants.users)
        .doc(sale.ownerId)
        .collection(AppConstants.ownerSales)
        .doc(updatedSale.id);

    batch.set(refModerate, {
      ...updatedSale.toJson(),
      'dateAdded': FieldValue.serverTimestamp(),
    });

    batch.set(ref, {
      ...updatedSale.toJson(),
      'dateAdded': FieldValue.serverTimestamp(),
    });

    batch.set(historyRef, {
      ...history.toJson(),
      'date': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Future<ItemModel?> getPhoneByImei(String imei) async {
    final snap = await db.collection(AppConstants.items).where('imei1', isEqualTo: imei).get();
    if (snap.docs.isEmpty) return null;
    return ItemModel.fromJson(snap.docs.first.data());
  }

  @override
  Future<int> getPhoneBonus(String article) async {
    final querySnapshot = await db.collection(AppConstants.bonuses).get();

    if (querySnapshot.docs.isEmpty) {
      return 0;
    }

    final docRef = querySnapshot.docs.first.reference;

    return await db.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};
      final Map<String, dynamic> innerMap = data[AppConstants.bonuses] as Map<String, dynamic>? ?? {};

      final rawBonus = innerMap[article];

      return int.tryParse(rawBonus.toString()) ?? 0;
    });
  }
}
