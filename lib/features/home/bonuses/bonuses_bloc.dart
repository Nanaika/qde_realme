import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import 'bonuses_event.dart';
import 'bonuses_repository.dart';
import 'bonuses_state.dart';

class BonusesBloc extends Bloc<BonusesEvent, BonusesState> {
  final BonusesRepository repository;

  BonusesBloc({required this.repository}) : super(BonusesInitial()) {
    on<BonusesGetEvent>(_onGet);
    on<BonusesUpdateEvent>(_onUpdate);
  }

  Future<void> _onGet(BonusesGetEvent event, Emitter<BonusesState> emit) async {
    emit(BonusesLoading());

    try {
      final data = await repository.get();

      emit(BonusesSuccess(bonuses: data));
    } on Failure catch (failure) {
      emit(BonusesError(failure));
    } catch (e) {
      emit(BonusesError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onUpdate(BonusesUpdateEvent event, Emitter<BonusesState> emit) async {
    emit(BonusesLoading());

    try {
      await repository.update(event.bonuses);

      emit(BonusesUpdateSuccess());
    } on Failure catch (failure) {
      emit(BonusesError(failure));
    } catch (e) {
      emit(BonusesError(ServerFailure(e.toString())));
    }
  }
}
