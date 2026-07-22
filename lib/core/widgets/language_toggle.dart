import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';

import '../../generated/locale_keys.g.dart';
import '../theme/theme_dimensions.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  void _showLanguageDialog(BuildContext context) {
    final selectedLang = _getCurrentLanguage(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,

      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          body: SizedBox.expand(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingL),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: ThemeDimensions.paddingS),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: const Icon(CupertinoIcons.arrow_left),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'language'.tr(),
                            style: ThemeTextStyles.appBarTitle(context),
                          ),
                        ],
                      ),
                    ),
                    // Контент
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LangContainer(
                            isSelected: selectedLang == 'RU',
                            onTap: () {
                              context.setLocale(const Locale('ru'));
                              Navigator.of(context).pop();
                            },
                            text: 'russian'.tr(),
                            assetPath: 'assets/images/ru.png',
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          LangContainer(
                            isSelected: selectedLang == 'UZ',
                            onTap: () {
                              context.setLocale(const Locale('uz'));
                              Navigator.of(context).pop();
                            },
                            text: 'uzbek'.tr(),
                            assetPath: 'assets/images/uz.png',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    // return AlertDialog(
    //   title: Text(LocaleKeys.language_select.tr()),
    //   content: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       ListTile(
    //         leading: const Icon(CupertinoIcons.globe),
    //         title: Text(LocaleKeys.language_english.tr()),
    //         onTap: () {
    //           context.setLocale(const Locale('en'));
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //       ListTile(
    //         leading: const Icon(CupertinoIcons.globe),
    //         title: Text(LocaleKeys.language_russian.tr()),
    //         onTap: () {
    //           context.setLocale(const Locale('ru'));
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //     ],
    //   ),
    // );
  }

  String _getCurrentLanguage(BuildContext context) {
    final locale = context.locale;
    return locale.languageCode == 'ru' ? 'RU' : 'UZ';
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.globe),
          const SizedBox(width: 4),
          Text(
            _getCurrentLanguage(context),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      tooltip: LocaleKeys.language_change.tr(),
      onPressed: () => _showLanguageDialog(context),
    );
  }
}

class LangContainer extends StatefulWidget {
  const LangContainer({
    super.key,
    required this.text,
    required this.assetPath,
    this.onTap,
    this.isSelected = false,
  });

  final String text;
  final String assetPath;
  final void Function()? onTap;
  final bool isSelected;

  @override
  State<LangContainer> createState() => _LangContainerState();
}

class _LangContainerState extends State<LangContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: widget.isSelected ? const Color(0xFFF04973) : const Color(0xFFACACAC),
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              widget.assetPath,

              width: 24,
              height: 24,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(widget.text),
          ],
        ),
      ),
    );
  }
}
