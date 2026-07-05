import 'package:qde_realme/features/home/add_item/item_model.dart';

abstract class AddItemEvent {}

class AddEvent extends AddItemEvent {
  final ItemModel item;

  AddEvent(this.item);
}
