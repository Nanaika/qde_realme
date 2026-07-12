import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/history/history_model.dart';

import '../../../core/error/failures.dart';
import 'history_event.dart';
import 'history_repository.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository repository;

  HistoryBloc({required this.repository}) : super(HistoryStateInitial()) {
    on<HistoryGetFirstEvent>(_onGetFirst);
    on<HistoryGetNextEvent>(_onGetNext);
  }

  Future<void> _onGetFirst(
    HistoryGetFirstEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryStateLoading());

    try {
      final items = await repository.getFirst(event.userId);

      emit(HistoryStateSuccess(items: items));
    } on Failure catch (failure) {
      emit(HistoryStateError(failure));
    } catch (e) {
      emit(HistoryStateError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onGetNext(
    HistoryGetNextEvent event,
    Emitter<HistoryState> emit,
  ) async {
    // 1. Если репозиторий уже упёрся в конец базы — вообще ничего не делаем
    if (repository.hasReachedMax) return;

    // 2. Подгрузку делаем ТОЛЬКО если на экране уже есть успешный стейт с данными
    if (state is HistoryStateSuccess) {
      final currentState = state as HistoryStateSuccess;
      emit(currentState.copyWith(isMoreLoading: true));

      try {
        // Качаем следующую порцию данных
        final newItems = await repository.getNext(event.userId);

        // Объединяем старых юзеров из стейта и новых пришедших
        final updatedList = List<HistoryModel>.from(currentState.items)
          ..addAll(newItems);

        // Выплевываем обновленный стейт с полным списком
        emit(HistoryStateSuccess(items: updatedList));
      } on Failure catch (failure) {
        emit(HistoryStateError(failure));
      } catch (e) {
        emit(HistoryStateError(ServerFailure(e.toString())));
      }
    } else {
      // На случай, если getNext вызвали, когда экрана еще нет (дефолтный первый запуск)
      emit(HistoryStateLoading());
      try {
        final items = await repository.getFirst(
          event.userId,
        ); // Для первой пачки лучше юзать getFirst
        emit(HistoryStateSuccess(items: items));
      } catch (e) {
        emit(HistoryStateError(ServerFailure(e.toString())));
      }
    }
  }
}
