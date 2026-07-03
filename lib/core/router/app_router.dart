import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/pages/auth_gates.dart';
import 'package:qde_realme/features/auth/presentation/pages/login_page.dart';
import 'package:qde_realme/features/home/presentation/pages/confirm_account_page.dart';
import 'package:qde_realme/features/home/presentation/pages/home_page_slave.dart';

import '../../features/home/presentation/pages/home_page_admin.dart';

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

    ],
  );
}

