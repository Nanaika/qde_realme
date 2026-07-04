import 'package:qde_realme/features/home/slave_data/slave_data_model.dart';

import '../../../core/error/failures.dart';

abstract class SlaveDataState {}

class SlaveDataInitial extends SlaveDataState {}

class SlaveDataLoading extends SlaveDataState {}

class SlaveDataSuccess extends SlaveDataState {
   final SlaveDataModel data;
   SlaveDataSuccess(this.data);
}

class SlaveDataError extends SlaveDataState {
  final Failure failure;

  SlaveDataError(this.failure);
}