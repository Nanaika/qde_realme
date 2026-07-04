import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/core/widgets/language_toggle.dart';
import 'package:qde_realme/core/widgets/theme_toggle.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_event.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_state.dart';
import 'package:qde_realme/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';

class HomePageSlave extends StatefulWidget {
  const HomePageSlave({super.key});

  @override
  State<HomePageSlave> createState() => _HomePageSlaveState();
}

class _HomePageSlaveState extends State<HomePageSlave> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _check();
      _initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.home_title.tr()), actions: const [LanguageToggle(), ThemeToggle()]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: ThemeDimensions.spacingM),
          Text('SLAVE PAGE', style: ThemeTextStyles.headlineLarge(context), textAlign: TextAlign.center),
          SizedBox(height: ThemeDimensions.spacingS),
          // Text(
          //   LocaleKeys.home_description.tr(),
          //   style: ThemeTextStyles.bodyLarge(context),
          //   textAlign: TextAlign.center,
          // ),
          BlocConsumer<SlaveDataBloc, SlaveDataState>(
            builder: (BuildContext context, state) {
              if (state is SlaveDataLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SlaveDataSuccess) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('Bonuses = ${state.data.bonusesSum}'),
                      Text('accepted = ${state.data.acceptedSum}'),
                      Text('declined = ${state.data.declinedSum}'),
                      Text('waiting = ${state.data.awaitingSum}'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            listener: (BuildContext context, state) {
              if (state is SlaveDataError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add_sale');
        },
        child: Text('add sale'),
      ),
    );
  }

  Future<void> _check() async {
    final value = getIt<SharedPreferences>().getString(AppConstants.keyIsFirstEnter);

    if (value == null && mounted) {
      context.push('/confirm_account');
    }
  }

  Future<void> _initData() async {
    final id = (getIt<AuthBloc>().state as AuthAuthenticated).currentUser.id;
    getIt<SlaveDataBloc>().add(GetDataEvent(id));
  }
}
