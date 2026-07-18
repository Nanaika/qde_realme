import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/moferate_users/moderate_users_event.dart';
import 'package:qde_realme/features/home/moferate_users/moderate_users_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/app_constants.dart';
import '../../auth/data/models/user_model.dart';
import 'moderate_users_repository.dart';

class ModerateUsersBloc extends Bloc<ModerateUsersEvent, ModerateUsersState> {
  final ModerateUsersRepository repository;

  ModerateUsersBloc({required this.repository}) : super(ModerateUsersInitial()) {
    on<ModerateUsersGetFirstEvent>(_onGetFirst);
    on<ModerateUsersGetNextEvent>(_onGetNext);
    on<ModerateUserEvent>(_onModerateUser);
  }

  Future<void> _onModerateUser(
    ModerateUserEvent event,
    Emitter<ModerateUsersState> emit,
  ) async {
    // Действуем только если текущий стейт успешный и у нас есть список юзеров
    if (state is ModerateUsersSuccess) {
      final currentState = state as ModerateUsersSuccess;

      try {
        // 1. Сразу удаляем юзера из локального списка на UI, чтобы приложение не тупило
        // и юзер мгновенно исчезал с экрана (Optimistic UI)
        final updatedItems = List<UserModel>.from(currentState.items)..removeWhere((user) => user.id == event.userId);

        // Выплевываем обновленный список (без этого юзера)
        emit(currentState.copyWith(items: updatedItems));

        // 2. Стучимся в репозиторий к нашему батчу
        await repository.moderateUser(event.isModerated, event.userId);
      } on Failure catch (failure) {
        // Если сервак ответил ошибкой — возвращаем юзера обратно в список и показываем ошибку
        emit(ModerateUsersError(failure));
      } catch (e) {
        emit(ModerateUsersError(ServerFailure(e.toString())));
      }
    }
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
