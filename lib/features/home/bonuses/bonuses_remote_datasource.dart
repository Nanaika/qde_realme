import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';

abstract class BonusesRemoteDataSource {
  Future update(Map<String, String> bonuses);

  Future<Map<String, String>> get();
}

class BonusesRemoteDataSourceImpl implements BonusesRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<Map<String, String>> get() async {
    final snaps = await db.collection(AppConstants.bonuses).get();
    if (snaps.docs.isEmpty) return {};

    final data = snaps.docs.first.data();
    final Map<String, dynamic> innerMap = data['bonuses'] as Map<String, dynamic>? ?? {};

    final Map<String, String> bonusesMap = innerMap.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    return bonusesMap;
  }

  @override
  @override
  Future<dynamic> update(Map<String, String> bonuses) async {
    await db.runTransaction((transaction) async {
      final snaps = await db.collection(AppConstants.bonuses).get();

      if (snaps.docs.isNotEmpty) {
        final firstDocRef = snaps.docs.first.reference;

        // Убираем merge: true, чтобы старая мапа целиком заменялась на новую
        transaction.set(
          firstDocRef,
          {
            'bonuses': bonuses,
          },
        );
      }
    });
  }
}
