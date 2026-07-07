import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_type.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';

abstract class ModerateSalesRemoteDataSource {
  Future<List<SaleModel>> getFirst();

  Future<List<SaleModel>> getNext();

  Future<void> moderateSale(SaleModel sale, bool isAccepted);
}

class ModerateSalesRemoteDataSourceImpl implements ModerateSalesRemoteDataSource {
  final db = FirebaseFirestore.instance;
  final limit = 20;

  DocumentSnapshot? _lastDocument;
  bool hasReachedMax = false;

  @override
  Future<List<SaleModel>> getFirst() async {
    hasReachedMax = false;

    final querySnapshot = await db.collection(AppConstants.moderateSales).limit(limit).get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;

      if (querySnapshot.docs.length < limit) {
        hasReachedMax = true;
      }
    } else {
      _lastDocument = null;
      hasReachedMax = true; // Сразу пусто
    }

    return querySnapshot.docs.map((doc) => SaleModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<SaleModel>> getNext() async {
    if (hasReachedMax || _lastDocument == null) return [];

    final querySnapshot = await db
        .collection(AppConstants.moderateSales)
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

    return querySnapshot.docs.map((doc) => SaleModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> moderateSale(SaleModel sale, bool isAccepted) async {
    // Ссылка на документ в модерации (по нему проверяем, занят ли сейл)
    final moderateSaleRef = db.collection(AppConstants.moderateSales).doc(sale.id);

    final saleRef = db
        .collection(AppConstants.users)
        .doc(sale.ownerId)
        .collection(AppConstants.ownerSales)
        .doc(sale.id);

    final historyRef = db
        .collection(AppConstants.users)
        .doc(sale.ownerId)
        .collection(AppConstants.history)
        .doc();

    final status = isAccepted ? AddSaleType.accepted.name : AddSaleType.declined.name;

    // Запускаем транзакцию
    await db.runTransaction((transaction) async {
      // 1. ОБЯЗАТЕЛЬНОЕ ЧТЕНИЕ: проверяем, существует ли еще сейл в модерации
      final moderateSnapshot = await transaction.get(moderateSaleRef);

      if (!moderateSnapshot.exists) {
        // Если дока уже нет, значит другой админ обработал его на миллисекунду раньше
        throw Exception('Этот сейл уже обработан другим администратором');
      }

      // 2. ЕСЛИ ВСЕ ОК — ЗАПИСЫВАЕМ ДАННЫЕ В ОДИН МИГ
      transaction.update(saleRef, {'type': status});
      transaction.delete(moderateSaleRef);
      transaction.set(historyRef, {
        'date': FieldValue.serverTimestamp(),
        'message': 'Sale ${sale.id} was $status',
      });
    });
  }
}
