import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_event.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_event.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_colors.dart';

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
      // appBar: AppBar(title: Text(LocaleKeys.home_title.tr()), actions: const [LanguageToggle(), ThemeToggle()]),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text(
              //   LocaleKeys.home_description.tr(),
              //   style: ThemeTextStyles.bodyLarge(context),
              //   textAlign: TextAlign.center,
              // ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      final String text;
                      if (state is AuthAuthenticated) {
                        final name = state.currentUser.name != '' || state.currentUser.name != null
                            ? state.currentUser.name
                            : '';
                        if (name != '') {
                          text = 'hello_user'.tr(args: [?state.currentUser.name]) + '';
                        } else {
                          text = 'hello'.tr();
                        }
                      } else {
                        text = 'hello'.tr();
                      }
                      return Expanded(
                        child: Text(
                          text,
                          maxLines: 2,
                          style: ThemeTextStyles.headlineLarge(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push('/history');
                    },
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.transparent),
                      child: const Icon(CupertinoIcons.clock),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: BlocConsumer<SlaveDataBloc, SlaveDataState>(
                  builder: (BuildContext context, state) {
                    if (state is SlaveDataLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SlaveDataSuccess) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _initData();
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'total'.tr(),
                                  style: ThemeTextStyles.custom(
                                    context: context,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 17,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A243A),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Center(
                                  child: Text(
                                    '${state.data.bonusesSum} USD',
                                    style: ThemeTextStyles.custom(
                                      context: context,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 34,
                              ),

                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              overflow: TextOverflow.ellipsis,
                                              'accepted'.tr(),
                                              style: ThemeTextStyles.custom(
                                                context: context,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 17,
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A243A),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${state.data.acceptedSum}',
                                                  style: ThemeTextStyles.custom(
                                                    context: context,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF27ED5F),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              'declined'.tr(),
                                              overflow: TextOverflow.ellipsis,
                                              style: ThemeTextStyles.custom(
                                                context: context,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 17,
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A243A),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${state.data.declinedSum}',
                                                  style: ThemeTextStyles.custom(
                                                    context: context,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFFFF472F),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 34,
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              'waiting'.tr(),
                                              overflow: TextOverflow.ellipsis,
                                              style: ThemeTextStyles.custom(
                                                context: context,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 17,
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A243A),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${state.data.awaitingSum}',
                                                  style: ThemeTextStyles.custom(
                                                    context: context,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFFFFEF40),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              'paid'.tr(),
                                              overflow: TextOverflow.ellipsis,
                                              style: ThemeTextStyles.custom(
                                                context: context,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 17,
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2A243A),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${state.data.paidSum}',
                                                  style: ThemeTextStyles.custom(
                                                    context: context,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFFBFBDBD),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  context.push('/homeadmin');
                                },
                                child: const Text('Change to admin'),
                              ),
                              const SizedBox(
                                height: 60,
                              ),
                            ],
                          ),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ThemeColors.primaryDark,

        onPressed: () {
          context.push('/add_sale');
        },
        label: Text('add_sale'.tr()),
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
    getIt<AuthBloc>().add(RefreshEvent());
  }
}
