import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/services/remote_config_service.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_admin.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_slave.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomeGates extends StatelessWidget {
  const HomeGates({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final admins = getIt<RemoteConfigService>().getJson(AppConstants.adminEmails);

        final contains = admins.values.contains((authState as AuthAuthenticated).currentUser.email);

        if (contains) {
          return const HomePageAdmin();
        } else {
          return const HomePageSlave();
        }
      },
    );
  }
}
