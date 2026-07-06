import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ModerateUsersRemoteDataSource {
  Future<List<UserModel>> getFirst();

  Future<List<UserModel>> getNext();
}

class ModerateUsersRemoteDataSourceImpl implements ModerateUsersRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final limit = 5;

  DocumentSnapshot? _lastDocument;
  bool hasReachedMax = false;

  @override
  Future<List<UserModel>> getFirst() async {
    hasReachedMax = false;

    final querySnapshot = await db.collection(AppConstants.moderateUsers).limit(limit).get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      if (querySnapshot.docs.length < limit) {
        hasReachedMax = true;
      }
    } else {
      _lastDocument = null;
      hasReachedMax = true; // Сразу пусто
    }

    return querySnapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<UserModel>> getNext() async {
    if (hasReachedMax || _lastDocument == null) return [];

    final querySnapshot = await db
        .collection(AppConstants.moderateUsers)
        .startAfterDocument(_lastDocument!)
        .limit(limit)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      if (querySnapshot.docs.length < limit) {
        hasReachedMax = true;
      }
    } else {
      hasReachedMax = true;
    }

    return querySnapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
}
