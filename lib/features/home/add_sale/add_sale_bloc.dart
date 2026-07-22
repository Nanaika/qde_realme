import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_event.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_repository.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_state.dart';

import '../../../core/error/failures.dart';

class AddSaleBloc extends Bloc<AddSaleEvent, AddSaleState> {
  final AddSaleRepository repository;

  AddSaleBloc({required this.repository}) : super(AddSaleInitial()) {
    on<AddEvent>(_onAddSale);
    on<GetPhoneByImeiEvent>(_onGetPhoneByImei);
    on<AddSaleResetEvent>((event, emit) => emit(AddSaleInitial()));
  }

  Future<void> _onAddSale(AddEvent event, Emitter<AddSaleState> emit) async {
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

  Future<void> _onGetPhoneByImei(GetPhoneByImeiEvent event, Emitter<AddSaleState> emit) async {
    emit(AddSaleLoading());

    try {
      final item = await repository.getPhoneByImei(event.imei);
      if (item == null) {
        emit(AddSaleError(const PhoneNotFoundFailure()));
        return;
      }
      final bonus = await repository.getPhoneBonus(item.article);
      emit(GetPhoneByImeiSuccess(item, bonus));
    } on Failure catch (failure) {
      emit(AddSaleError(failure));
    } catch (e) {
      emit(AddSaleError(ServerFailure(e.toString())));
    }
  }
}
