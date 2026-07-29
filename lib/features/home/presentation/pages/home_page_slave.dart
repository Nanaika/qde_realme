import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_colors.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/presentation/pages/settings_page.dart';
import 'package:qde_realme/features/home/presentation/pages/slave_home_content_page.dart';

class HomePageSlave extends StatefulWidget {
  const HomePageSlave({super.key});

  @override
  State<HomePageSlave> createState() => _HomePageSlaveState();
}

class _HomePageSlaveState extends State<HomePageSlave> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthAuthenticated) {
          if (state.isUserLoaded) {
            if (!state.currentUser.isModerated && !state.onModeration) {
              context.push('/confirm_account');
            }
          }
        }
      },
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [SlaveHomeContentPage(), SettingsPage()],
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
      ),
    );
  }
}
