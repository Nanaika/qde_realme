import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_colors.dart';
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
                        return const Center(child: Text('Empty'));
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
                            final sale = state.items[index];
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2A243A),
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.device_phone_portrait),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          sale.imei,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.person_alt_circle),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          sale.ownerId,
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.money_dollar),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Expanded(
                                        child: Text(
                                          sale.bonus.toString(),
                                          style: ThemeTextStyles.headlineSmall(
                                            context,
                                          ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            context.read<ModerateSalesBloc>().add(
                                              ModerateSaleEvent(sale: state.items[index], isAccepted: false),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: ThemeColors.primaryDark,
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Reject',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            context.read<ModerateSalesBloc>().add(
                                              ModerateSaleEvent(sale: state.items[index], isAccepted: true),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: ThemeColors.success,
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Approve',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
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
