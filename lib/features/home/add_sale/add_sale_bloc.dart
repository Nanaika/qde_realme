import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_event.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_repository.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_state.dart';

import '../../../core/error/failures.dart';

class AddSaleBloc extends Bloc<AddSaleEvent, AddSaleState> {
  final AddSaleRepository repository;

  AddSaleBloc({required this.repository}) : super(AddSaleInitial()) {
    on<AddEvent>(_onConfirmAccount);
  }

  Future<void> _onConfirmAccount(AddEvent event, Emitter<AddSaleState> emit) async {
    emit(AddSaleLoading());

    try {
      await repository.add(event.sale);

      emit(AddSaleSuccess());
    } on Failure catch (failure) {
      emit(AddSaleError(failure));
    } catch (e) {
      emit(AddSaleError(ServerFailure(e.toString())));
    }
  }
}
