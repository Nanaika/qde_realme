import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ConfirmAccountRemoteDataSource {
  Future confirm(UserModel user);
}

class ConfirmAccountRemoteDataSourceImpl implements ConfirmAccountRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> confirm(UserModel user) async{
    await db.collection(AppConstants.moderateUsers).doc(user.id).set(user.toJson());
  }
}
