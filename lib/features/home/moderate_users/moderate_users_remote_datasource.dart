import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/home/history/history_model.dart';
import 'package:qde_realme/features/home/history/history_type.dart';

abstract class ModerateUsersRemoteDataSource {
  Future<List<UserModel>> getFirst();

  Future<List<UserModel>> getNext();

  Future<void> moderateUser(bool isModerated, String userId);
}

class ModerateUsersRemoteDataSourceImpl implements ModerateUsersRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final limit = 20;

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

  @override
  Future<void> moderateUser(bool isModerated, String userId) async {
    // 1. Создаем батч
    final batch = db.batch();

    // 2. Ссылки на документы
    final userModerateModelSnap = await db.collection(AppConstants.moderateUsers).doc(userId).get();
    final userModel = UserModel.fromJson(userModerateModelSnap.data() ?? {});
    final userRef = db.collection(AppConstants.users).doc(userId);
    final moderateUserRef = db.collection(AppConstants.moderateUsers).doc(userId);
    final historyRef = db
        .collection(AppConstants.users)
        .doc(userId)
        .collection(AppConstants.history)
        .doc(); // .doc() без параметров создает новый ID для add-операции

    // 3. Навешиваем операции на батч
    batch.update(userRef, {...userModel.toJson(), 'isModerated': isModerated});
    batch.delete(moderateUserRef);
    final history = HistoryModel(
      message: userId,
      type: isModerated ? HistoryType.userAccepted.name : HistoryType.userDeclined.name,
    );
    batch.set(historyRef, {
      ...history.toJson(),
      'date': FieldValue.serverTimestamp(),
    });

    // 4. Пуляем всё это одним махом в базу
    await batch.commit();
  }
}
