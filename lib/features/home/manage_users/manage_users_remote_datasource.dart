import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_type.dart';

import '../../auth/data/models/user_model.dart';
import '../add_sale/sale_model.dart';
import '../history/history_model.dart';
import '../history/history_type.dart';

abstract class ManageUsersRemoteDatasource {
  Future get();

  Future getUserSales(String id);

  Future<void> pay(String userId, String saleId);
}

class ManageUsersRemoteDataSourceImpl implements ManageUsersRemoteDatasource {
  final db = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> get() async {
    final snaps = await db.collection(AppConstants.users).get();

    return snaps.docs.map((doc) {
      return UserModel.fromJson(doc.data());
    }).toList();
  }

  @override
  Future<void> pay(String userId, String saleId) async {
    final docRef = db.collection(AppConstants.users).doc(userId).collection(AppConstants.ownerSales).doc(saleId);

    final historyRef = db.collection(AppConstants.users).doc(userId).collection(AppConstants.history).doc();

    await db.runTransaction((transaction) async {
      // --- 1. СТРОГО СНАЧАЛА ВСЕ ЧТЕНИЯ ---
      final docSnap = await transaction.get(docRef);

      if (!docSnap.exists) {
        throw Exception('Doc dont exist');
      }

      final data = docSnap.data();
      if (data == null || data['type'] != 'accepted') {
        throw Exception('This sale has already been processed by another administrator.');
      }

      final history = HistoryModel(
        message: data['imei'],
        type: HistoryType.imeiPaid.name,
        bonus: data['bonus'].toString(),
        skuName: data['skuName'],
      );

      // --- 2. ТОЛЬКО ПОТОМ ВСЕ ЗАПИСИ ---
      transaction.update(docRef, {
        'type': 'paid',
      });

      transaction.set(historyRef, {
        ...history.toJson(),
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<dynamic> getUserSales(String id) async {
    final snaps = await db
        .collection(AppConstants.users)
        .doc(id)
        .collection(AppConstants.ownerSales)
        .where('type', isEqualTo: AddSaleType.accepted.name)
        .get();

    return snaps.docs.map((doc) {
      return SaleModel.fromJson(doc.data());
    }).toList();
  }
}
