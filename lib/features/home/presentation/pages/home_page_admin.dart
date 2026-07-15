import 'package:firebase_auth/firebase_auth.dart';
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
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
                    child: AdminButton(
                      text: 'Import',
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
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
                    child: AdminButton(
                      text: 'Sales',
                      onTap: () {},
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
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
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
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: ThemeDimensions.spacingM),
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.push('/add_item');
                },
                child: Text('add item screen'),
              ),
              SizedBox(height: ThemeDimensions.spacingXL),
              ElevatedButton(
                onPressed: () {
                  context.push('/moderate_users');
                },
                child: Text('MODERATE USERS'),
              ),

              SizedBox(height: ThemeDimensions.spacingM),
              ElevatedButton(
                onPressed: () {
                  context.push('/moderate_sales');
                },
                child: Text('MODERATE SALES'),
              ),

              SizedBox(height: ThemeDimensions.spacingM),
              ElevatedButton(
                onPressed: () {
                  context.push('/homeslave');
                },
                child: Text('Change to slave'),
              ),

              SizedBox(height: ThemeDimensions.spacingXL),
              ElevatedButton(
                onPressed: () {
                  context.push('/bonuses');
                },
                child: Text('Bonuses'),
              ),

              ElevatedButton(
                onPressed: () {
                  context.push('/manage_users');
                },
                child: Text('Manage users'),
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
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(ThemeDimensions.radiusL),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Text(
                text,
                style: ThemeTextStyles.headlineMedium(context).copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
