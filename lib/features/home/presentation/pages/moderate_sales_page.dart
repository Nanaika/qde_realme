import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.transparent),
                      child: const Icon(CupertinoIcons.arrow_left),
                    ),
                  ),
                  SizedBox(
                    width: ThemeDimensions.paddingM,
                  ),
                  Text(
                    'Moderate sales',
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              Expanded(
                child: BlocBuilder<ModerateSalesBloc, ModerateSalesState>(
                  builder: (context, state) {
                    if (state is ModerateSalesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ModerateSalesError) {
                      return Center(child: Text(state.failure.message));
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
                          physics: const AlwaysScrollableScrollPhysics(),
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
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.id,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.ownerId,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.imei,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.type.name,
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    user.dateAdded.toString(),
                                    style: ThemeTextStyles.headlineSmall(
                                      context,
                                    ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.read<ModerateSalesBloc>().add(
                                            ModerateSaleEvent(sale: state.items[index], isAccepted: true),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: const Text('confirm'),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<ModerateSalesBloc>().add(
                                            ModerateSaleEvent(sale: state.items[index], isAccepted: false),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: const Text('decline'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
      ),
    );
  }
}
