import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/auth/presentation/pages/login_page.dart';
import 'package:qde_realme/features/home/presentation/pages/home_gates.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_slave.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthGates extends StatelessWidget {
  const AuthGates({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          // final isDark = context.read<ThemeBloc>().isDark;
          // if (isDark) {
          //   setDarkSystemBars();
          // } else {
          //   setLightSystemBars();
          // }
          return const HomeGates();
        } else {
          // setDarkSystemBars();
          return const LoginPage();
        }
      },
    );
  }
}
