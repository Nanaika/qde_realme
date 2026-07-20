import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_event.dart';

import '../../../../core/theme/theme_colors.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ThemeDimensions.spacingXL),

              Text(
                'Device Management',
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: ThemeDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      text: 'Enter',
                      onTap: () {
                        context.push('/add_single_item');
                      },
                      icon: CupertinoIcons.square_pencil,
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
                    child: AdminButton(
                      text: 'Import',
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
                'Moderate',
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: ThemeDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      text: 'Sellers',
                      icon: CupertinoIcons.checkmark_shield_fill,
                      onTap: () {
                        context.push('/moderate_users');
                      },
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
                    child: AdminButton(
                      text: 'Sales',
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
                'Users',
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: ThemeDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      text: 'Users',
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
                'Bonuses management',
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
              ),
              SizedBox(height: ThemeDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      text: 'Bonuses',
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

              ElevatedButton(
                onPressed: () {
                  context.push('/homeslave');
                },
                child: Text('Change to slave'),
              ),

              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                child: Text('Logout'),
              ),
            ],
          ),
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
    this.iconSize = 20,
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
                width: 40,
                height: 40,
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
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
