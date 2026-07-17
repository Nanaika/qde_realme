import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/uz_cities.dart';
import '../../confirm_account/confirm_account_bloc.dart';
import '../../confirm_account/confirm_account_event.dart';
import '../../confirm_account/confirm_account_state.dart';

class ConfirmAccountPage extends StatefulWidget {
  const ConfirmAccountPage({super.key});

  @override
  State<ConfirmAccountPage> createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  late final TextEditingController numberController;
  late final TextEditingController nameController;
  String? _selectedCityKey;
  String? _selectedDistrictKey;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    nameController = TextEditingController();
  }

  void _showCityPickerDialog() async {
    final citiesMap = LocationTranslator.getCities(context);

    final String? resultKey = await showDialog<String>(
      context: context,
      builder: (context) => LocationSelectionDialog(
        title: 'Select city',
        locations: citiesMap,
      ),
    );

    if (resultKey != null) {
      setState(() {
        _selectedCityKey = resultKey;
        if (_selectedCityKey != 'tashkent_city') {
          _selectedDistrictKey = null; // Сброс района, если выбран другой город
        }
      });
    }
  }

  void _showDistrictPickerDialog() async {
    final districtsMap = LocationTranslator.getTashkentDistricts(context);

    final String? resultKey = await showDialog<String>(
      context: context,
      builder: (context) => LocationSelectionDialog(
        title: 'Select district',
        locations: districtsMap,
      ),
    );

    if (resultKey != null) {
      setState(() {
        _selectedDistrictKey = resultKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmAccountBloc, ConfirmAccountState>(
      builder: (BuildContext context, state) {
        if (state is ConfirmAccountLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Confirm account',
                          style: ThemeTextStyles.titleMedium(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tile(
                              title: 'Telephon number',
                              hintText: '998 90 123 45 67',
                              controller: numberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textStyle: ThemeTextStyles.headlineMedium(
                                context,
                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Tile(
                              title: 'Name',
                              hintText: 'John Doe',
                              controller: nameController,
                              textStyle: ThemeTextStyles.headlineMedium(
                                context,
                              ).copyWith(color: Colors.black, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            LocationTile(
                              title: 'Select city',
                              selectedValue: _selectedCityKey != null
                                  ? LocationTranslator.translate(context, _selectedCityKey!)
                                  : null,
                              onTap: () {
                                _showCityPickerDialog();
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            LocationTile(
                              title: 'Select district',
                              selectedValue: _selectedDistrictKey != null
                                  ? LocationTranslator.translate(context, _selectedDistrictKey!)
                                  : null,
                              onTap: () {
                                if (_selectedCityKey == 'tashkent_city') _showDistrictPickerDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    MainButton(
                      onTap: () {
                        if (nameController.text.isEmpty || numberController.text.isEmpty || _selectedCityKey == null) {
                          ErrorDialog.show(context, 'Enter name number and city');
                          return;
                        }
                        final currentUser = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser;
                        final userModel = UserModel(
                          id: currentUser.id,
                          email: currentUser.email,
                          name: nameController.text,
                          number: numberController.text,
                          city: _selectedCityKey,
                          district: _selectedDistrictKey ?? '',
                        );

                        context.read<ConfirmAccountBloc>().add(ConfirmEvent(userModel));
                      },
                      text: 'Confirm',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, state) {
        if (state is ConfirmAccountSuccess) {
          context.pop();
        } else if (state is ConfirmAccountError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
    );
  }
}

class LocationSelectionDialog extends StatelessWidget {
  final String title;
  final Map<String, String> locations;

  const LocationSelectionDialog({
    super.key,
    required this.title,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    final entries = locations.entries.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Шапка
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),
            // Просто скроллящийся список без лишнего дерьма
            Expanded(
              child: ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry.value),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onTap: () {
                      // Возвращаем ключ (например, 'chilanzar')
                      Navigator.pop(context, entry.key);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final String title; // Например: 'Город / Область'
  final String? selectedValue; // Сюда передаешь уже переведенную строку из словаря или null
  final VoidCallback onTap; // Метод, который открывает твой диалог

  const LocationTile({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Приятный серый фон
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Заголовок тайла слева
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Отображение выбора или заглушки справа
            Text(
              selectedValue ?? 'Выбрать',
              style: TextStyle(
                fontSize: 16,
                fontWeight: selectedValue != null ? FontWeight.w600 : FontWeight.normal,
                color: selectedValue != null ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
