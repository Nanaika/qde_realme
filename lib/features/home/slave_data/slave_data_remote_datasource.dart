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
    final acceptedSnaps = await db.collection(AppConstants.users).doc(id).collection(AppConstants.ownerSales).where(
        'type', isEqualTo:  'accepted').get();
    final declinedSnaps = await db.collection(AppConstants.users).doc(id).collection(AppConstants.ownerSales).where(
        'type', isEqualTo:  'declined').get();
    final onModerationSnaps = await db.collection(AppConstants.users).doc(id).collection(AppConstants.ownerSales).where(
        'type', isEqualTo:  'onModeration').get();

    return SlaveDataModel(bonusesSum: acceptedSnaps.size * 50,
        acceptedSum: acceptedSnaps.size,
        declinedSum: declinedSnaps.size,
        awaitingSum: onModerationSnaps.size);
  }
}
