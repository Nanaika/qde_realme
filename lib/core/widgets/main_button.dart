import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/theme_colors.dart';
import '../theme/theme_dimensions.dart';
import '../theme/theme_text_styles.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    this.onTap,
    this.text = '',
    this.isApple = false,
  });

  final void Function()? onTap;
  final String text;
  final bool isApple;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.widthOf(context) / 1.6,
      child: ElevatedButton(
        onPressed: onTap,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: ThemeTextStyles.button(context).copyWith(fontSize: 16, fontWeight: FontWeight.w300),
            ),
            if (isApple)
              const SizedBox(
                width: 10,
              ),
            if (isApple)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Image.asset(
                  'assets/images/apple.png',
                  color: Colors.white,
                  width: 22,
                  height: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
