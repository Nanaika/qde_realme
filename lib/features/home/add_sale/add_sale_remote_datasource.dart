import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class AddSaleRemoteDataSource {
  Future add(SaleModel sale);
}

class AddSaleRemoteDataSourceImpl implements AddSaleRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(SaleModel sale) async {
    final batch = db.batch();

    final refModerate = db.collection(AppConstants.moderateSales).doc();

    final updatedSale = sale.copyWith(id: refModerate.id);

    final ref = db
        .collection(AppConstants.users)
        .doc(sale.ownerId)
        .collection(AppConstants.ownerSales)
        .doc(updatedSale.id);

    batch.set(refModerate, {...updatedSale.toJson(), 'dateAdded': FieldValue.serverTimestamp()});

    batch.set(ref, {...updatedSale.toJson(), 'dateAdded': FieldValue.serverTimestamp()});

    await batch.commit();
  }
}
