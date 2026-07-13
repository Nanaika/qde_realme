import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/widgets/language_toggle.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_event.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/widgets/main_button.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, state) {
        if (state is AuthLoading) {
        } else if (state is AuthUnauthenticated || state is AuthInitial) {
        } else {}
      },
      child: Scaffold(
        // appBar: AppBar(title: Text(LocaleKeys.auth_login.tr()), actions: const [LanguageToggle(), ThemeToggle()]),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(ThemeDimensions.paddingS),
            child: Column(
              children: [
                const Row(
                  children: [
                    LanguageToggle(),
                  ],
                ),
                Image.asset(
                  'assets/images/auth.png',
                  height: MediaQuery.heightOf(context) / 2.5,
                ),
                const SizedBox(
                  height: 35,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingL),
                  child: Column(
                    children: [
                      Text(
                        'SET YOUR FINANCIAL GOALS',
                        style: ThemeTextStyles.headlineLarge(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'We help our users to make the right financial decisions',
                        style: ThemeTextStyles.bodyMedium(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                MainButton(
                  onTap: () {
                    context.read<AuthBloc>().add(LoginEvent());
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
