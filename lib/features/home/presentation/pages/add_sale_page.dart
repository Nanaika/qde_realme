import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_event.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_state.dart';
import 'package:qde_realme/features/home/add_sale/sale_model.dart';
import 'package:qde_realme/features/home/presentation/pages/imei_scanner_screen.dart';

class AddSalePage extends StatefulWidget {
  const AddSalePage({super.key});

  @override
  State<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSaleBloc, AddSaleState>(
      builder: (BuildContext context, state) {
        if (state is AddSaleLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Text('add sale page'),
                TextField(controller: controller),
                ElevatedButton(
                  onPressed: () {
                    final ownerId = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                    final sale = SaleModel(imei: controller.text, ownerId: ownerId, id: '', bonus: 0);
                    context.read<AddSaleBloc>().add(AddEvent(sale));
                  },
                  child: Text('send'),
                ),
                ElevatedButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) { return const ImeiScannerScreen(); }));
                }, child: Text('test'))
              ],
            ),
          ),
        );
      },
      listener: (BuildContext context, state) {
        if (state is AddSaleSuccess) {
          context.pop();
        } else if (state is AddSaleError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
    );
  }
}
