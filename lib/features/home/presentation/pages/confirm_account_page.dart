import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/widgets/main_button.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
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
        title: 'select_city'.tr(),
        locations: citiesMap,
      ),
    );

    if (resultKey != null) {
      setState(() {
        _selectedCityKey = resultKey;
        if (_selectedCityKey != 'tashkent_city') {
          _selectedDistrictKey = null;
        }
      });
    }
  }

  void _showDistrictPickerDialog() async {
    final districtsMap = LocationTranslator.getTashkentDistricts(context);

    final String? resultKey = await showDialog<String>(
      context: context,
      builder: (context) => LocationSelectionDialog(
        title: 'select_district'.tr(),
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
                          'confirm_account'.tr(),
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
                              title: 'telephone_number'.tr(),
                              hintText: '998 90 123 45 67',
                              controller: numberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textStyle: ThemeTextStyles.headlineMedium(
                                context,
                              ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Tile(
                              title: 'name'.tr(),
                              hintText: 'John Doe',
                              controller: nameController,
                              textStyle: ThemeTextStyles.headlineMedium(
                                context,
                              ).copyWith(color: Colors.white, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            LocationTile(
                              title: 'select_city'.tr(),
                              selectedValue: _selectedCityKey != null
                                  ? LocationTranslator.translate(context, _selectedCityKey!)
                                  : null,
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _showCityPickerDialog();
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            LocationTile(
                              title: 'select_district'.tr(),
                              selectedValue: _selectedDistrictKey != null
                                  ? LocationTranslator.translate(context, _selectedDistrictKey!)
                                  : null,
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (_selectedCityKey == 'tashkent_city') _showDistrictPickerDialog();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    MainButton(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (nameController.text.isEmpty || numberController.text.isEmpty || _selectedCityKey == null) {
                          ErrorDialog.show(context, 'enter_name_number_city'.tr());
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
                      text: 'confirm'.tr(),
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
      backgroundColor: const Color(0xFF2A243A),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

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
  final String title;
  final String? selectedValue;
  final VoidCallback onTap;

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
          color: const Color(0xFF2A243A), // Приятный серый фон
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                selectedValue ?? 'select'.tr(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selectedValue != null ? FontWeight.w600 : FontWeight.normal,
                  color: selectedValue != null ? Colors.white : Colors.grey,
                ),
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
