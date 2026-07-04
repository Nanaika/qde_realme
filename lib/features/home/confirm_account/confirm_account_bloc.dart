import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import 'confirm_account_event.dart';
import 'confirm_account_repository.dart';
import 'confirm_account_state.dart';

class ConfirmAccountBloc extends Bloc<ConfirmAccountEvent, ConfirmAccountState> {
  final ConfirmAccountRepository repository;

  ConfirmAccountBloc({required this.repository}) : super(ConfirmAccountInitial()) {
    on<ConfirmEvent>(_onConfirmAccount);
  }

  Future<void> _onConfirmAccount(ConfirmEvent event, Emitter<ConfirmAccountState> emit) async {
    emit(ConfirmAccountLoading());

    try {
      await repository.confirm(event.user);

      emit(ConfirmAccountSuccess());
    } on Failure catch (failure) {
      emit(ConfirmAccountError(failure));
    } catch (e) {
      emit(ConfirmAccountError(ServerFailure(e.toString())));
    }
  }
}
