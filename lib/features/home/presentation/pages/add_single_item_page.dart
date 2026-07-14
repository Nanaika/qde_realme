import 'package:flutter/material.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';

import '../../../../core/theme/theme_colors.dart';

class AddSingleItemPage extends StatelessWidget {
  const AddSingleItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(LocaleKeys.home_title.tr()),
      //   actions: const [LanguageToggle(), ThemeToggle()],
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
