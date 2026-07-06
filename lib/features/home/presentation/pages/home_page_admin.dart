import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_border_styles.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/widgets/language_toggle.dart';
import 'package:qde_realme/core/widgets/theme_toggle.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/generated/locale_keys.g.dart';

import '../../../auth/presentation/bloc/auth_state.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

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
            Text(
              'ADMIN PAGE',
              style: ThemeTextStyles.headlineLarge(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ThemeDimensions.spacingS),
            ElevatedButton(onPressed: () {
              context.push('/add_item');
            }, child: Text('add item screen')),
            SizedBox(height: ThemeDimensions.spacingXL),
            ElevatedButton(onPressed: () {
              context.push('/moderate_users');
            }, child: Text('MODERATE USERS')),

            SizedBox(height: ThemeDimensions.spacingM),


            SizedBox(height: ThemeDimensions.spacingM),


            SizedBox(height: ThemeDimensions.spacingXL),


          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeBorderStyles.cardBorderRadius(context),
        child: Container(
          padding: EdgeInsets.all(ThemeDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(ThemeDimensions.paddingM * 0.75),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeDimensions.radiusS),
                ),
                child: Icon(icon, color: color, size: ThemeDimensions.iconL),
              ),
              SizedBox(width: ThemeDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ThemeTextStyles.cardTitle(context)),
                    SizedBox(height: ThemeDimensions.spacingXS),
                    Text(description, style: ThemeTextStyles.cardSubtitle(context)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: ThemeDimensions.iconXS, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
