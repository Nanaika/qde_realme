import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

import '../history/history_model.dart';
import '../history/history_type.dart';

abstract class ConfirmAccountRemoteDataSource {
  Future confirm(UserModel user);
}

class ConfirmAccountRemoteDataSourceImpl implements ConfirmAccountRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> confirm(UserModel user) async {
    await db.collection(AppConstants.moderateUsers).doc(user.id).set(user.toJson());

    final batch = db.batch();

    final moderateRef = db.collection(AppConstants.moderateUsers).doc(user.id);
    final historyRef = db.collection(AppConstants.users).doc(user.id).collection(AppConstants.history).doc();

    final userData = user.toJson();
    final history = HistoryModel(
      message: user.id,
      type: HistoryType.userPending.name,
    );

    batch.set(moderateRef, userData);
    batch.set(historyRef, {
      ...history.toJson(),
      'date': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
