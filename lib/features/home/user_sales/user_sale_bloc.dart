import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/user_sales/user_sales_event.dart';
import 'package:qde_realme/features/home/user_sales/user_sales_state.dart';

import '../add_sale/sale_model.dart';
import '../manage_users/manage_users_repository.dart';

class UserSalesBloc extends Bloc<UserSalesEvent, UserSalesState> {
  final ManageUsersRepository repository;

  UserSalesBloc({required this.repository}) : super(UserSalesInitial()) {
    on<GetSalesEvent>(_onGetSales);
    on<PaySaleEvent>(_onPaySale);
  }

  Future<void> _onGetSales(GetSalesEvent event, Emitter<UserSalesState> emit) async {
    emit(UserSalesLoading());
    try {
      final sales = await repository.getUserSales(event.id);
      emit(UserSalesSuccess(sales));
    } catch (e) {
      emit(UserSalesError(e.toString()));
    }
  }

  Future<void> _onPaySale(PaySaleEvent event, Emitter<UserSalesState> emit) async {
    final currentSales = state is UserSalesSuccess
        ? (state as UserSalesSuccess).data
        : <SaleModel>[]; // Замени SaleModel на свой класс модели
    emit(UserSalesLoading());
    try {
      await repository.pay(event.id, event.saleId);
      final updatedSales = currentSales.where((sale) => sale.id != event.saleId).toList();

      emit(UserSalesSuccess(updatedSales));
    } catch (e) {
      emit(UserSalesError(e.toString()));
    }
  }
}
