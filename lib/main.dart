import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qde_realme/core/di/injection_container.dart';
import 'package:qde_realme/core/notifications/notification_service.dart';
import 'package:qde_realme/core/router/app_router.dart';
import 'package:qde_realme/core/services/theme_service.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_bloc.dart';
import 'package:qde_realme/generated/locale_keys.g.dart';
import 'package:showcaseview/showcaseview.dart';

import 'features/home/add_item/add_item_bloc.dart';
import 'features/home/add_items/add_items_bloc.dart';
import 'features/home/bonuses/bonuses_bloc.dart';
import 'features/home/confirm_account/confirm_account_bloc.dart';
import 'features/home/history/history_bloc.dart';
import 'features/home/moderate_sales/moderate_sales_bloc.dart';
import 'features/home/moferate_users/moderate_users_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await initDependencies();

  if (getIt.isRegistered<NotificationService>()) {
    try {
      final notificationService = getIt<NotificationService>();
      await notificationService.initialize();

      final token = await notificationService.getFCMToken();
      if (token != null) {
        print('FCM Token: $token');
        print(
          'Используйте этот токен для отправки тестовых уведомлений из Firebase Console',
        );
      }
    } catch (e) {
      print('Ошибка инициализации уведомлений: $e');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      startLocale: Locale('en'),
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
          BlocProvider<ConfirmAccountBloc>(
            create: (_) => getIt<ConfirmAccountBloc>(),
          ),
          BlocProvider<AddSaleBloc>(create: (_) => getIt<AddSaleBloc>()),
          BlocProvider<SlaveDataBloc>(create: (_) => getIt<SlaveDataBloc>()),
          BlocProvider<AddItemBloc>(create: (_) => getIt<AddItemBloc>()),
          BlocProvider<AddItemsBloc>(create: (_) => getIt<AddItemsBloc>()),
          BlocProvider<ModerateUsersBloc>(
            create: (_) => getIt<ModerateUsersBloc>(),
          ),
          BlocProvider<ModerateSalesBloc>(
            create: (_) => getIt<ModerateSalesBloc>(),
          ),
          BlocProvider<HistoryBloc>(create: (_) => getIt<HistoryBloc>()),
          BlocProvider<BonusesBloc>(create: (_) => getIt<BonusesBloc>()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = getIt<ThemeService>();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _themeService.themeModeStream.listen((mode) {
      if (mounted) {
        setState(() {
          _themeMode = mode;
        });
      }
    });
  }

  Future<void> _loadTheme() async {
    final mode = await _themeService.getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone X design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: LocaleKeys.app_name,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: _themeMode,
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}
