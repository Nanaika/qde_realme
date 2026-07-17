import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/theme/theme_dimensions.dart';
import 'package:qde_realme/core/theme/theme_text_styles.dart';
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_event.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_state.dart';
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
              Text(
                'Hello',
                style: ThemeTextStyles.headlineLarge(context),
              ),
              BlocConsumer<SlaveDataBloc, SlaveDataState>(
                builder: (BuildContext context, state) {
                  if (state is SlaveDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SlaveDataSuccess) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _initData();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.heightOf(context) / 6,
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  '${state.data.bonusesSum} \$',
                                  style: ThemeTextStyles.headlineLarge(context).copyWith(color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.heightOf(context) / 10,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'accepted = ${state.data.acceptedSum}',
                                        style: ThemeTextStyles.bodySmall(context).copyWith(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.heightOf(context) / 10,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'declined = ${state.data.declinedSum}',
                                        style: ThemeTextStyles.bodySmall(context).copyWith(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.heightOf(context) / 10,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'waiting = ${state.data.awaitingSum}',
                                        style: ThemeTextStyles.bodySmall(context).copyWith(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  child: Container(
                                    height: MediaQuery.heightOf(context) / 10,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'paid = ${state.data.paidSum}',
                                        style: ThemeTextStyles.bodySmall(context).copyWith(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            ElevatedButton(
                              onPressed: () {
                                context.push('/homeadmin');
                              },
                              child: Text('Change to admin'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.push('/history');
                              },
                              child: Text('history'),
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
            ],
          ),
        ),
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
