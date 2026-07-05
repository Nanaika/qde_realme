import 'package:qde_realme/features/home/add_item/item_model.dart';

abstract class AddItemsEvent {}

class AddMEvent extends AddItemsEvent {
  final List<ItemModel> items;

  AddMEvent(this.items);
}

class ParseEvent extends AddItemsEvent {
  final String path;

  ParseEvent(this.path);
}

class SaveExcelEvent extends AddItemsEvent {}
