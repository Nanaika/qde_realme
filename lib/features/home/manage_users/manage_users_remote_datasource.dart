import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';

import '../../auth/data/models/user_model.dart';
import '../history/history_model.dart';
import '../history/history_type.dart';

abstract class ManageUsersRemoteDatasource {
  Future get();

  Future<void> pay(String userId);
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
  Future<void> pay(String userId) async {
    await db.runTransaction((transaction) async {
      final queryRef = db
          .collection(AppConstants.users)
          .doc(userId)
          .collection(AppConstants.ownerSales)
          .where('type', isEqualTo: 'accepted');
      final historyRef = db.collection(AppConstants.users).doc(userId).collection(AppConstants.history);

      final snaps = await queryRef.get();
      for (var doc in snaps.docs) {
        transaction.update(doc.reference, {
          'type': 'paid', // Сетим новое состояние
        });

        final history = HistoryModel(message: doc.data()['imei'], type: HistoryType.imeiPaid.name);

        final newDocRef = historyRef.doc();

        transaction.set(newDocRef, {
          ...history.toJson(),
          'date': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
