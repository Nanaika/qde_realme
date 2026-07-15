import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../theme/theme_dimensions.dart';
import '../theme/theme_text_styles.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this._onTap,
    this.text = '',
  });
  final void Function()? _onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.widthOf(context) / 1.6,
      child: ElevatedButton(
        onPressed: _onTap,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeDimensions.radiusL),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(ThemeColors.primaryDark),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: ThemeDimensions.paddingXL,
              vertical: ThemeDimensions.paddingM,
            ),
          ),
        ),
        child: Text(
          text,
          style: ThemeTextStyles.button(context).copyWith(fontSize: 16, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}
