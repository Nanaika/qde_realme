import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/home/bonuses/bonuses_event.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../bonuses/bonuses_bloc.dart';
import '../../bonuses/bonuses_state.dart';

class BonusesPage extends StatefulWidget {
  const BonusesPage({super.key});

  @override
  State<BonusesPage> createState() => _BonusesPageState();
}

class _BonusesPageState extends State<BonusesPage> {
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    context.read<BonusesBloc>().add(BonusesGetEvent());
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  void _clearControllers() {
    for (var controller in _keyControllers) {
      controller.dispose();
    }
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    _keyControllers.clear();
    _valueControllers.clear();
  }

  void _initializeControllers(Map<String, String> bonuses) {
    _clearControllers();
    bonuses.forEach((key, value) {
      _keyControllers.add(TextEditingController(text: key));
      _valueControllers.add(TextEditingController(text: value));
    });
  }

  void _addNewBonusField() {
    setState(() {
      _keyControllers.add(TextEditingController(text: ''));
      _valueControllers.add(TextEditingController(text: ''));
    });
  }

  void _removeBonusField(int index) {
    setState(() {
      _keyControllers[index].dispose();
      _valueControllers[index].dispose();
      _keyControllers.removeAt(index);
      _valueControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BonusesBloc, BonusesState>(
      listener: (context, state) {
        if (state is BonusesSuccess) {
          _initializeControllers(state.bonuses);
          setState(() {});
        }
        if (state is BonusesUpdateSuccess) {
          context.read<BonusesBloc>().add(BonusesGetEvent());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ThemeDimensions.paddingM,
              vertical: ThemeDimensions.paddingM,
            ),
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
                    SizedBox(width: ThemeDimensions.paddingM),
                    Text(
                      'fcm_bonuses'.tr(),
                      style: ThemeTextStyles.titleMedium(context),
                    ),
                    const Spacer(),
                    // Кнопка сохранения соберет всё из контроллеров в мапу
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final Map<String, String> updatedMap = {};
                        for (int i = 0; i < _keyControllers.length; i++) {
                          final newKey = _keyControllers[i].text.trim();
                          final newValue = _valueControllers[i].text.trim();
                          if (newKey.isNotEmpty) {
                            updatedMap[newKey] = newValue;
                          }
                        }
                        context.read<BonusesBloc>().add(BonusesUpdateEvent(bonuses: updatedMap));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                BlocBuilder<BonusesBloc, BonusesState>(
                  buildWhen: (previous, current) => current is! BonusesUpdateSuccess,
                  builder: (context, state) {
                    if (state is BonusesLoading) {
                      return const Expanded(child: Center(child: CircularProgressIndicator()));
                    }

                    if (state is BonusesError) {
                      return Expanded(child: Center(child: Text('${'error'.tr()}: ${state.failure}')));
                    }

                    if (_keyControllers.isEmpty && state is! BonusesSuccess) {
                      return const SizedBox.shrink();
                    }

                    return Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _keyControllers.isEmpty
                                ? Center(child: Text('list_of_bonuses_empty'.tr()))
                                : ListView.separated(
                                    itemCount: _keyControllers.length,
                                    separatorBuilder: (ctx, index) => const SizedBox(height: 20),
                                    itemBuilder: (ctx, index) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A243A),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          children: [
                                            CustomTextField(
                                              textStyle: ThemeTextStyles.headlineMedium(
                                                context,
                                              ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                              hintText: 'article_'.tr(),
                                              controller: _keyControllers[index],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: CustomTextField(
                                                    textStyle: ThemeTextStyles.headlineMedium(
                                                      context,
                                                    ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                                                    hintText: 'bonus_'.tr(),
                                                    controller: _valueControllers[index],
                                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: ThemeColors.primaryDark,
                                                  ),
                                                  onPressed: () => _removeBonusField(index),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),

                          MainButton(
                            onTap: () {
                              _addNewBonusField();
                            },
                            text: 'add_bonus'.tr(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
