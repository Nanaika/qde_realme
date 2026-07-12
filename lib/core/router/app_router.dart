import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/pages/auth_gates.dart';
import 'package:qde_realme/features/auth/presentation/pages/login_page.dart';
import 'package:qde_realme/features/home/presentation/pages/add_sale_page.dart';
import 'package:qde_realme/features/home/presentation/pages/confirm_account_page.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_slave.dart';
import 'package:qde_realme/features/home/presentation/pages/moderate_users_page.dart';

import '../../features/home/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/add_item_page.dart';
import '../../features/home/presentation/pages/home_page_admin.dart';
import '../../features/home/presentation/pages/moderate_sales_page.dart';

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
        path: '/add_item',
        name: 'add_item',
        builder: (context, state) => const AddItemPage(),
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
    ],
  );
}
