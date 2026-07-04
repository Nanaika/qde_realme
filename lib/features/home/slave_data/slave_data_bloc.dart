import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_event.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_repository.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_state.dart';

import '../../../core/error/failures.dart';

class SlaveDataBloc extends Bloc<SlaveDataEvent, SlaveDataState> {
  final SlaveDataRepository repository;

  SlaveDataBloc({required this.repository}) : super(SlaveDataInitial()) {
    on<GetDataEvent>(_onGetSlaveData);
  }

  Future<void> _onGetSlaveData(GetDataEvent event, Emitter<SlaveDataState> emit) async {
    emit(SlaveDataLoading());

    try {
     final data = await repository.getData(event.id);

      emit(SlaveDataSuccess(data));
    } on Failure catch (failure) {
      emit(SlaveDataError(failure));
    } catch (e) {
      emit(SlaveDataError(ServerFailure(e.toString())));
    }
  }
}
