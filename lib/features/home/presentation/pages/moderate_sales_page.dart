import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';

import '../../moderate_sales/moderate_sales_bloc.dart';
import '../../moderate_sales/moderate_sales_event.dart';
import '../../moderate_sales/moderate_sales_state.dart';

class ModerateSalesPage extends StatefulWidget {
  const ModerateSalesPage({super.key});

  @override
  State<ModerateSalesPage> createState() => _ModerateSalesPageState();
}

class _ModerateSalesPageState extends State<ModerateSalesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ТУТ ПИНАЕМ БЛОК НА СТАРТЕ (Поменяй на свой эвент, например LoadUsers())
    context.read<ModerateSalesBloc>().add(ModerateSalesGetFirstEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // ТУТ ПОДГРУЖАЕМ СЛЕДУЮЩУЮ ПАЧКУ (Поменяй на свой эвент, например GetNextUsers())
      context.read<ModerateSalesBloc>().add(ModerateSalesGetNextEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text("MODERATE USERS PAGE"),
            Expanded(
              child: BlocBuilder<ModerateSalesBloc, ModerateSalesState>(
                builder: (context, state) {
                  if (state is ModerateSalesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ModerateSalesError) {
                    return const Center(child: Text("Error"));
                  }
                  if (state is ModerateSalesSuccess) {
                    if (state.items.isEmpty) {
                      return const Center(child: Text("Empty"));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ModerateSalesBloc>().add(ModerateSalesGetFirstEvent());
                      },
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final user = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.blue),
                              child: Column(
                                children: [
                                  Text(user.id),
                                  Text(user.ownerId),
                                  Text(user.imei),
                                  Text(user.type.name),
                                  Text(user.dateAdded.toString()),

                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {

                                          context.read<ModerateSalesBloc>().add(
                                            ModerateSaleEvent(sale: state.items[index], isAccepted: true),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('confirm'),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<ModerateSalesBloc>().add(
                                            ModerateSaleEvent(sale: state.items[index], isAccepted: false),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('decline'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // Вместо пустого SizedBox возвращаем крутилку для Initial стейта
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
