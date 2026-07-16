import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/add_item/item_model.dart';

abstract class AddItemsRemoteDataSource {
  Future add(List<ItemModel> item);
}

class AddItemsRemoteDataSourceImpl implements AddItemsRemoteDataSource {
  final db = FirebaseFirestore.instance;

  @override
  Future<void> add(List<ItemModel> item) async {
    final collectionRef = FirebaseFirestore.instance.collection(AppConstants.items); // Твоя коллекция
    const int batchSize = 499;

    try {
      for (int i = 0; i < item.length; i += batchSize) {
        // Отрезаем кусок в 499 элементов (или меньше, если это остаток списка)
        final end = (i + batchSize < item.length) ? i + batchSize : item.length;
        final chunk = item.sublist(i, end);

        // Создаем новый батч для текущей пачки
        final batch = FirebaseFirestore.instance.batch();

        for (final element in chunk) {
          // Создаем новый документ с авто-генерацией ID
          final docRef = collectionRef.doc();

          // Превращаем модель в мапу. Если у тебя метод называется по-другому (например, toMap), поменяй.
          final data = element.toJson();

          // Записываем ID документа внутрь данных, если это необходимо
          data['id'] = docRef.id;
          data['date'] = FieldValue.serverTimestamp();

          batch.set(docRef, data);
        }

        // Пуляем пачку в базу и ждем завершения, прежде чем брать следующую
        await batch.commit();
      }
    } catch (e) {
      rethrow; // Прокидываем ошибку дальше в Блок, если надо её там поймать
    }
  }
}
