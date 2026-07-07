import 'package:qde_realme/features/home/add_sale/sale_model.dart';

import '../../../core/error/failures.dart';

abstract class ModerateSalesState {}

class ModerateSalesInitial extends ModerateSalesState {}

class ModerateSalesLoading extends ModerateSalesState {}

class ModerateSalesSuccess extends ModerateSalesState {
  final List<SaleModel> items;
  final bool isMoreLoading;
  final String? error;

  ModerateSalesSuccess({required this.items, this.isMoreLoading = false, this.error});

  ModerateSalesSuccess copyWith({List<SaleModel>? items, bool? isMoreLoading, String? error}) {
    return ModerateSalesSuccess(
      items: items ?? this.items,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      error: error ?? this.error,
    );
  }
}

class ModerateSalesError extends ModerateSalesState {
  final Failure failure;

  ModerateSalesError(this.failure);
}
