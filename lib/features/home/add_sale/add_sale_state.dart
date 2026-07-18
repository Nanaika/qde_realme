import 'package:qde_realme/features/home/add_item/item_model.dart';

import '../../../core/error/failures.dart';

abstract class AddSaleState {}

class AddSaleInitial extends AddSaleState {}

class AddSaleLoading extends AddSaleState {}

class AddSaleSuccess extends AddSaleState {}

class AddSaleGetBonusSuccess extends AddSaleState {
  final int bonus;
  AddSaleGetBonusSuccess(this.bonus);
}

class GetPhoneByImeiSuccess extends AddSaleState {
  final ItemModel item;
  final int bonus;
  GetPhoneByImeiSuccess(this.item, this.bonus);
}

class AddSaleError extends AddSaleState {
  final Failure failure;

  AddSaleError(this.failure);
}
