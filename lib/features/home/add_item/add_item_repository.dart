import 'package:qde_realme/features/home/add_item/item_model.dart';

abstract class AddItemRepository {
  Future add(ItemModel item);
}
