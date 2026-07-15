import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/services/excel_service.dart';

import '../../../core/error/failures.dart';
import 'add_items_event.dart';
import 'add_items_repository.dart';
import 'add_items_state.dart';

class AddItemsBloc extends Bloc<AddItemsEvent, AddItemsState> {
  final AddItemsRepository repository;
  final ExcelService excelService;

  AddItemsBloc({required this.repository, required this.excelService}) : super(AddItemsInitial()) {
    on<AddMEvent>(_onAddM);
    on<ParseEvent>(_onParseExcel);
    on<SaveExcelEvent>(_onSaveExcel);
  }

  Future<void> _onSaveExcel(SaveExcelEvent event, Emitter<AddItemsState> emit) async {
    emit(AddItemsLoading());
    try {
      await repository.add(excelService.innerItems);

      emit(AddItemsSuccess());
    } on Failure catch (failure) {
      emit(AddItemsError(failure));
    } catch (e) {
      emit(AddItemsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onParseExcel(ParseEvent event, Emitter<AddItemsState> emit) async {
    emit(AddItemsLoading());
    try {
      await excelService.parse(event.path);

      emit(AddItemsSuccess());
    } on Failure catch (failure) {
      emit(AddItemsError(failure));
    } catch (e) {
      emit(AddItemsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onAddM(AddMEvent event, Emitter<AddItemsState> emit) async {
    emit(AddItemsLoading());

    try {
      await repository.add(event.items);

      emit(AddItemsSuccess());
    } on Failure catch (failure) {
      emit(AddItemsError(failure));
    } catch (e) {
      emit(AddItemsError(ServerFailure(e.toString())));
    }
  }
}
