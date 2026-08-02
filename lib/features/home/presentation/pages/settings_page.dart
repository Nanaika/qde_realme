import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_colors.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_event.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';
import '../../../../core/widgets/language_toggle.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'settings'.tr(),
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              SettingsRow(
                text: 'language'.tr(),
                icon: CupertinoIcons.globe,
                onTap: () {
                  showLanguageDialog(context);
                },
              ),
              const SizedBox(
                height: 36,
              ),
              SettingsRow(
                text: 'terms_and_conditions'.tr(),
                icon: CupertinoIcons.doc_text,
                onTap: () {
                  context.push('/privacy_page');
                },
              ),
              const SizedBox(
                height: 18,
              ),
              SettingsRow(
                text: 'privacy_policy'.tr(),
                icon: CupertinoIcons.shield,
                onTap: () {
                  context.push('/privacy_page', extra: true);
                },
              ),

              const SizedBox(
                height: 36,
              ),
              SettingsRow(
                text: 'logout'.tr(),
                icon: CupertinoIcons.square_arrow_right,
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
              ),
              const SizedBox(
                height: 18,
              ),
              SettingsRow(
                text: 'delete_user'.tr(),
                icon: CupertinoIcons.person_crop_circle_badge_minus,
                textColor: ThemeColors.primaryDark,
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (dialogContext) => AdaptiveDialog(
                      title: 'deleting_user'.tr(),
                      content: 'are_you_sure_you_want_to_delete_the_user'.tr(),
                      cancelText: 'no'.tr(),
                      confirmText: 'yes'.tr(),
                      onConfirm: () {
                        final id = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                        context.read<AuthBloc>().add(DeleteUserEvent(userId: id));
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.onTap,
    this.icon,
    this.text = '',
    this.textColor,
  });

  final void Function()? onTap;
  final IconData? icon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Icon(
                icon,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text,
                style: ThemeTextStyles.inputText(context).copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showLanguageDialog(BuildContext context) {
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
}

String _getCurrentLanguage(BuildContext context) {
  final locale = context.locale;
  return locale.languageCode == 'ru' ? 'RU' : 'UZ';
}

class AdaptiveDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const AdaptiveDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirm,
    this.confirmColor = ThemeColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: ThemeTextStyles.labelLarge(context).copyWith(color: Colors.white),
          ),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: Text(
            confirmText,
            style: ThemeTextStyles.labelLarge(context).copyWith(color: confirmColor),
          ),
        ),
      ],
    );
  }
}
