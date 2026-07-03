import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/core/widgets/language_toggle.dart';
import 'package:qde_realme/core/widgets/theme_toggle.dart';
import 'package:qde_realme/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';

class HomePageSlave extends StatefulWidget {
  const HomePageSlave({super.key});

  @override
  State<HomePageSlave> createState() => _HomePageSlaveState();
}

class _HomePageSlaveState extends State<HomePageSlave> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _check();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.home_title.tr()), actions: const [LanguageToggle(), ThemeToggle()]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ThemeDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ThemeDimensions.spacingM),
            Text('SLAVE PAGE', style: ThemeTextStyles.headlineLarge(context), textAlign: TextAlign.center),
            SizedBox(height: ThemeDimensions.spacingS),
            Text(
              LocaleKeys.home_description.tr(),
              style: ThemeTextStyles.bodyLarge(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeDimensions.spacingXL),

            SizedBox(height: ThemeDimensions.spacingM),

            SizedBox(height: ThemeDimensions.spacingM),

            SizedBox(height: ThemeDimensions.spacingXL),
          ],
        ),
      ),
    );
  }

  Future<void> _check() async {
    final value = getIt<SharedPreferences>().getString(AppConstants.keyIsFirstEnter);

    if (value == null && mounted) {
      context.push('/confirm_account');
    }
  }
}
