import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/moferate_users/moderate_users_event.dart';
import 'package:qde_realme/features/home/moferate_users/moderate_users_state.dart';

import '../../../core/error/failures.dart';
import '../../auth/data/models/user_model.dart';
import 'moderate_users_repository.dart';

class ModerateUsersBloc extends Bloc<ModerateUsersEvent, ModerateUsersState> {
  final ModerateUsersRepository repository;

  ModerateUsersBloc({required this.repository}) : super(ModerateUsersInitial()) {
    on<ModerateUsersGetFirstEvent>(_onGetFirst);
    on<ModerateUsersGetNextEvent>(_onGetNext);
  }

  Future<void> _onGetFirst(ModerateUsersEvent event, Emitter<ModerateUsersState> emit) async {
    emit(ModerateUsersLoading());

    try {
      final items = await repository.getFirst();

      emit(ModerateUsersSuccess(items: items));
    } on Failure catch (failure) {
      emit(ModerateUsersError(failure));
    } catch (e) {
      emit(ModerateUsersError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onGetNext(ModerateUsersEvent event, Emitter<ModerateUsersState> emit) async {
    // 1. Если репозиторий уже упёрся в конец базы — вообще ничего не делаем
    if (repository.hasReachedMax) return;

    // 2. Подгрузку делаем ТОЛЬКО если на экране уже есть успешный стейт с данными
    if (state is ModerateUsersSuccess) {
      final currentState = state as ModerateUsersSuccess;
      emit(currentState.copyWith(isMoreLoading: true));

      try {
        // Качаем следующую порцию данных
        final newItems = await repository.getNext();

        // Объединяем старых юзеров из стейта и новых пришедших
        final updatedList = List<UserModel>.from(currentState.items)..addAll(newItems);

        // Выплевываем обновленный стейт с полным списком
        emit(ModerateUsersSuccess(items: updatedList));

      } on Failure catch (failure) {
        emit(ModerateUsersError(failure));
      } catch (e) {
        emit(ModerateUsersError(ServerFailure(e.toString())));
      }
    } else {
      // На случай, если getNext вызвали, когда экрана еще нет (дефолтный первый запуск)
      emit(ModerateUsersLoading());
      try {
        final items = await repository.getFirst(); // Для первой пачки лучше юзать getFirst
        emit(ModerateUsersSuccess(items: items));
      } catch (e) {
        emit(ModerateUsersError(ServerFailure(e.toString())));
      }
    }
  }
}
