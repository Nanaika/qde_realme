import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import 'add_item_event.dart';
import 'add_item_repository.dart';
import 'add_item_state.dart';

class AddItemBloc extends Bloc<AddItemEvent, AddItemState> {
  final AddItemRepository repository;

  AddItemBloc({required this.repository}) : super(AddItemInitial()) {
    on<AddEvent>(_onConfirmAccount);
  }

  Future<void> _onConfirmAccount(AddEvent event, Emitter<AddItemState> emit) async {
    emit(AddItemLoading());

    try {
      await repository.add(event.item);

      emit(AddItemSuccess());
    } on Failure catch (failure) {
      emit(AddItemError(failure));
    } catch (e) {
      emit(AddItemError(ServerFailure(e.toString())));
    }
  }
}
