import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/features/home/presentation/pages/settings_page.dart';

import '../../../../core/theme/theme_colors.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: const [AdminHomeContentPage(), SettingsPage()],
      ),
      bottomNavigationBar: StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setLocalState) {
          return BottomAppBar(
            height: 60,
            padding: EdgeInsets.zero,

            color: const Color(0xFF2A243A),
            child: Row(
              mainAxisAlignment: .spaceAround,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setLocalState(() {
                        _currentIndex = 0;
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    child: Container(
                      height: 60,
                      color: Colors.transparent,
                      child: Icon(
                        CupertinoIcons.house_alt,
                        size: 30,
                        color: _currentIndex != 0 ? Colors.white : ThemeColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setLocalState(() {
                        _currentIndex = 1;
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Icon(
                        CupertinoIcons.settings,
                        size: 30,
                        color: _currentIndex != 1 ? Colors.white : ThemeColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminHomeContentPage extends StatelessWidget {
  const AdminHomeContentPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ThemeDimensions.spacingXL),

            Text(
              'device_management'.tr(),
              style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
            ),
            SizedBox(height: ThemeDimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    text: 'enter'.tr(),
                    onTap: () {
                      context.push('/add_single_item');
                    },
                    icon: CupertinoIcons.square_pencil,
                  ),
                ),
                SizedBox(width: ThemeDimensions.spacingM),
                Expanded(
                  child: AdminButton(
                    text: 'import'.tr(),
                    icon: CupertinoIcons.square_arrow_down,
                    onTap: () {
                      context.push('/add_excel_items');
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: ThemeDimensions.spacingXL),

            Text(
              'moderate'.tr(),
              style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
            ),
            SizedBox(height: ThemeDimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    text: 'sellers'.tr(),
                    icon: CupertinoIcons.checkmark_shield_fill,
                    onTap: () {
                      context.push('/moderate_users');
                    },
                  ),
                ),
                SizedBox(width: ThemeDimensions.spacingM),
                Expanded(
                  child: AdminButton(
                    text: 'sales'.tr(),
                    icon: CupertinoIcons.bag_fill,
                    onTap: () {
                      context.push('/moderate_sales');
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: ThemeDimensions.spacingXL),

            Text(
              'users'.tr(),
              style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
            ),
            SizedBox(height: ThemeDimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    text: 'users'.tr(),
                    icon: CupertinoIcons.person_crop_circle_fill,
                    onTap: () {
                      context.push('/manage_users');
                    },
                  ),
                ),
                SizedBox(width: ThemeDimensions.spacingM),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
              ],
            ),

            SizedBox(height: ThemeDimensions.spacingXL),

            Text(
              'bonuses_management'.tr(),
              style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
            ),
            SizedBox(height: ThemeDimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    text: 'bonuses'.tr(),
                    icon: CupertinoIcons.creditcard,
                    onTap: () {
                      context.push('/bonuses');
                    },
                  ),
                ),
                SizedBox(width: ThemeDimensions.spacingM),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  const AdminButton({
    super.key,
    this.onTap,
    this.icon = Icons.supervised_user_circle,
    this.iconSize = 25,
    this.iconColor = Colors.white,
    this.text = '',
  });

  final void Function()? onTap;
  final IconData icon;
  final double? iconSize;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A243A),
            borderRadius: BorderRadius.all(
              Radius.circular(ThemeDimensions.radiusL),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: ThemeColors.primaryDark,
                  shape: BoxShape.circle,
                ),
                width: 50,
                height: 50,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.headlineSmall(context).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
