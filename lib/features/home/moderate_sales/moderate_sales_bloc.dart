import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../add_sale/sale_model.dart';
import 'moderate_sales_event.dart';
import 'moderate_sales_repository.dart';
import 'moderate_sales_state.dart';

class ModerateSalesBloc extends Bloc<ModerateSalesEvent, ModerateSalesState> {
  final ModerateSalesRepository repository;

  ModerateSalesBloc({required this.repository}) : super(ModerateSalesInitial()) {
    on<ModerateSalesGetFirstEvent>(_onGetFirst);
    on<ModerateSalesGetNextEvent>(_onGetNext);
    on<ModerateSaleEvent>(_onModerateSale);
  }

  Future<void> _onModerateSale(ModerateSaleEvent event, Emitter<ModerateSalesState> emit) async {
    // Действуем только если текущий стейт успешный и у нас есть список юзеров
    if (state is ModerateSalesSuccess) {
      final currentState = state as ModerateSalesSuccess;

      try {
        // 1. Сразу удаляем юзера из локального списка на UI, чтобы приложение не тупило
        // и юзер мгновенно исчезал с экрана (Optimistic UI)
        final updatedItems = List<SaleModel>.from(currentState.items)..removeWhere((sale) => sale.id == event.sale.id);

        // Выплевываем обновленный список (без этого юзера)
        emit(currentState.copyWith(items: updatedItems));

        // 2. Стучимся в репозиторий к нашему батчу
        await repository.moderateSale(event.sale, event.isAccepted);
      } on Failure catch (failure) {
        // Если сервак ответил ошибкой — возвращаем юзера обратно в список и показываем ошибку
        emit(ModerateSalesError(failure));
      } catch (e) {
        emit(ModerateSalesError(ServerFailure(e.toString())));
      }
    }
  }

  Future<void> _onGetFirst(ModerateSalesEvent event, Emitter<ModerateSalesState> emit) async {
    emit(ModerateSalesLoading());

    try {
      final items = await repository.getFirst();

      emit(ModerateSalesSuccess(items: items));
    } on Failure catch (failure) {
      emit(ModerateSalesError(failure));
    } catch (e) {
      emit(ModerateSalesError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onGetNext(ModerateSalesEvent event, Emitter<ModerateSalesState> emit) async {
    // 1. Если репозиторий уже упёрся в конец базы — вообще ничего не делаем
    if (repository.hasReachedMax) return;

    // 2. Подгрузку делаем ТОЛЬКО если на экране уже есть успешный стейт с данными
    if (state is ModerateSalesSuccess) {
      final currentState = state as ModerateSalesSuccess;
      emit(currentState.copyWith(isMoreLoading: true));

      try {
        // Качаем следующую порцию данных
        final newItems = await repository.getNext();

        // Объединяем старых юзеров из стейта и новых пришедших
        final updatedList = List<SaleModel>.from(currentState.items)..addAll(newItems);

        // Выплевываем обновленный стейт с полным списком
        emit(ModerateSalesSuccess(items: updatedList));
      } on Failure catch (failure) {
        emit(ModerateSalesError(failure));
      } catch (e) {
        emit(ModerateSalesError(ServerFailure(e.toString())));
      }
    } else {
      // На случай, если getNext вызвали, когда экрана еще нет (дефолтный первый запуск)
      emit(ModerateSalesLoading());
      try {
        final items = await repository.getFirst(); // Для первой пачки лучше юзать getFirst
        emit(ModerateSalesSuccess(items: items));
      } catch (e) {
        emit(ModerateSalesError(ServerFailure(e.toString())));
      }
    }
  }
}
