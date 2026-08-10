import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/core/di/injection_container.dart';
import 'package:qde_realme/features/auth/presentation/pages/auth_gates.dart';
import 'package:qde_realme/features/auth/presentation/pages/login_page.dart';
import 'package:qde_realme/features/home/manage_users/manage_users_repository.dart';
import 'package:qde_realme/features/home/presentation/pages/add_excel_items.dart';
import 'package:qde_realme/features/home/presentation/pages/add_sale_page.dart';
import 'package:qde_realme/features/home/presentation/pages/add_single_item_page.dart';
import 'package:qde_realme/features/home/presentation/pages/bonuses_page.dart';
import 'package:qde_realme/features/home/presentation/pages/confirm_account_page.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_slave.dart';
import 'package:qde_realme/features/home/presentation/pages/imei_scanner_screen.dart';
import 'package:qde_realme/features/home/presentation/pages/manage_users_page.dart';
import 'package:qde_realme/features/home/presentation/pages/moderate_users_page.dart';
import 'package:qde_realme/features/home/presentation/pages/user_sales_page.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/home/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page_admin.dart';
import '../../features/home/presentation/pages/moderate_sales_page.dart';
import '../../features/home/presentation/pages/privacy_page.dart';
import '../../features/home/user_sales/user_sale_bloc.dart';
import '../../features/home/user_sales/user_sales_event.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'auth_gates',
        builder: (context, state) => const AuthGates(),
      ),
      GoRoute(
        path: '/homeadmin',
        name: 'homeadmin',
        builder: (context, state) => const HomePageAdmin(),
      ),
      GoRoute(
        path: '/homeslave',
        name: 'homeslave',
        builder: (context, state) => const HomePageSlave(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/confirm_account',
        name: 'confirm_account',
        builder: (context, state) => const ConfirmAccountPage(),
      ),
      GoRoute(
        path: '/add_sale',
        name: 'add_sale',
        builder: (context, state) => const AddSalePage(),
      ),
      GoRoute(
        path: '/moderate_users',
        name: 'moderate_users',
        builder: (context, state) => const ModerateUsersPage(),
      ),
      GoRoute(
        path: '/moderate_sales',
        name: 'moderate_sales',
        builder: (context, state) => const ModerateSalesPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/bonuses',
        name: 'bonuses',
        builder: (context, state) => const BonusesPage(),
      ),
      GoRoute(
        path: '/manage_users',
        name: 'manage_users',
        builder: (context, state) => const ManageUsersPage(),
      ),
      GoRoute(
        path: '/add_single_item',
        name: 'add_single_item',
        builder: (context, state) => const AddSingleItemPage(),
      ),
      GoRoute(
        path: '/add_excel_items',
        name: 'add_excel_items',
        builder: (context, state) => const AddExcelItems(),
      ),
      GoRoute(
        path: '/imei_scanner_page',
        name: 'imei_scanner_page',
        builder: (context, state) => const ImeiScannerScreen(),
      ),

      GoRoute(
        path: '/privacy_page',
        name: 'privacy_page',
        builder: (context, state) {
          final isPrivacy = (state.extra as bool?) ?? false;
          return PrivacyPage(
            isPrivacy: isPrivacy,
          );
        },
      ),
      GoRoute(
        path: '/user_sales',
        builder: (context, state) {
          final user = state.extra as UserModel;

          return BlocProvider(
            create: (context) => UserSalesBloc(
              repository: getIt<ManageUsersRepository>(),
            )..add(GetSalesEvent(user.id)),
            child: UserSalesPage(
              user: user,
            ),
          );
        },
      ),
    ],
  );
}
