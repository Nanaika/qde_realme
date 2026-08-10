import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import 'manage_users_event.dart';
import 'manage_users_repository.dart';
import 'manage_users_state.dart';

class ManageUsersBloc extends Bloc<ManageUsersEvent, ManageUsersState> {
  final ManageUsersRepository repository;

  ManageUsersBloc({required this.repository}) : super(ManageUsersInitial()) {
    on<ManageUsersGetEvent>(_onGet);
  }

  Future<void> _onGet(ManageUsersGetEvent event, Emitter<ManageUsersState> emit) async {
    emit(ManageUsersLoading());

    try {
      final users = await repository.get();

      emit(ManageUsersSuccess(users: users));
    } on Failure catch (failure) {
      emit(ManageUsersError(failure));
    } catch (e) {
      emit(ManageUsersError(ServerFailure(e.toString())));
    }
  }
}
