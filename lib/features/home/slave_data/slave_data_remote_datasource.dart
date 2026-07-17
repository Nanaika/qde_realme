import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_model.dart';

abstract class SlaveDataRemoteDataSource {
  Future<SlaveDataModel> getData(String id);
}

class SlaveDataRemoteDataSourceImpl implements SlaveDataRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<SlaveDataModel> getData(String id) async {
    // Запускаем все запросы одновременно
    final results = await Future.wait([
      db
          .collection(AppConstants.users)
          .doc(id)
          .collection(AppConstants.ownerSales)
          .where('type', isEqualTo: 'accepted')
          .get(),
      db
          .collection(AppConstants.users)
          .doc(id)
          .collection(AppConstants.ownerSales)
          .where('type', isEqualTo: 'declined')
          .get(),
      db
          .collection(AppConstants.users)
          .doc(id)
          .collection(AppConstants.ownerSales)
          .where('type', isEqualTo: 'onModeration')
          .get(),
      db
          .collection(AppConstants.users)
          .doc(id)
          .collection(AppConstants.ownerSales)
          .where('type', isEqualTo: 'paid')
          .get(),
    ]);

    final acceptedSnaps = results[0];
    final declinedSnaps = results[1];
    final onModerationSnaps = results[2];
    final onPaidSnaps = results[3];

    final int totalBonuses = acceptedSnaps.docs.fold<int>(0, (sum, doc) {
      final data = doc.data();

      final bonus = data['bonus'] as num? ?? 0;
      return sum + bonus.toInt();
    });

    return SlaveDataModel(
      bonusesSum: totalBonuses, // Если тут логика подсчета суммы из прошлой задачи, перепишешь локально через цикл
      acceptedSum: acceptedSnaps.size,
      declinedSum: declinedSnaps.size,
      awaitingSum: onModerationSnaps.size,
      paidSum: onPaidSnaps.size,
    );
  }
}
