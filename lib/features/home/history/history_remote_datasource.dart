import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/history/history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getFirst(String userId);

  Future<List<HistoryModel>> getNext(String userId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final limit = 20;

  DocumentSnapshot? _lastDocument;
  bool hasReachedMax = false;

  @override
  Future<List<HistoryModel>> getFirst(String userId) async {
    hasReachedMax = false;

    final querySnapshot = await db
        .collection(AppConstants.users)
        .doc(userId)
        .collection(AppConstants.history)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      if (querySnapshot.docs.length < limit) {
        hasReachedMax = true;
      }
    } else {
      _lastDocument = null;
      hasReachedMax = true;
    }

    return querySnapshot.docs
        .map((doc) => HistoryModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<HistoryModel>> getNext(String userId) async {
    if (hasReachedMax || _lastDocument == null) return [];

    final querySnapshot = await db
        .collection(AppConstants.users)
        .doc(userId)
        .collection(AppConstants.history)
        .orderBy('date', descending: true)
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

    return querySnapshot.docs
        .map((doc) => HistoryModel.fromJson(doc.data()))
        .toList();
  }
}
