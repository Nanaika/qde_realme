import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/widgets/language_toggle.dart';
import 'package:qde_realme/core/widgets/theme_toggle.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_event.dart';
import 'package:qde_realme/generated/locale_keys.g.dart';

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
        appBar: AppBar(title: Text(LocaleKeys.auth_login.tr()), actions: const [LanguageToggle(), ThemeToggle()]),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {


            return LoginWidget();

            // return state.maybeWhen(
            //   initial: () => const SizedBox.shrink(),
            //   loading: () =>
            //       LoadingWidget(message: LocaleKeys.common_loading.tr()),
            //   authenticated: (user) => _AuthenticatedView(user: user),
            //   unauthenticated: () => const SizedBox(height: 0,),
            //   error: (failure) => ErrorDisplayWidget(
            //     failure: failure,
            //     onRetry: () {
            //
            //     },
            //   ),
            //   orElse: () => const SizedBox.shrink(),
            // );
          },
        ),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthBloc>().add(LoginEvent());
      },
      child: Text('login'),
    );
  }
}
