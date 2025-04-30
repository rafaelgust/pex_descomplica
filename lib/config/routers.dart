import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/services/auth_service.dart';

import '../data/services/injector/injector_service.dart';

import '../ui/views/customers_view.dart';
import '../ui/views/dashboard_view.dart';

import '../ui/views/login_view.dart';
import '../ui/views/orders_view.dart';
import '../ui/views/profile_view.dart';
import '../ui/views/reports_view.dart';
import '../ui/views/settings_view.dart';
import '../ui/views/stock_view.dart';
import '../ui/views/suppliers_view.dart';
import '../ui/views/widgets/nav_rail_page.dart';

class Routers {
  // method go and back route
  static void goToPath(BuildContext context, String path) {
    context.go(path);
  }

  static void goToNamed(BuildContext context, String name) {
    context.goNamed(name);
  }

  static void goBack(BuildContext context) {
    context.pop();
  }

  static String? getPath(BuildContext context) {
    return GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.last.route.name;
  }
}

GoRouter appRouter() {
  final AuthService authService = injector.get<AuthService>();

  return GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const LoginView(),
            ),
        redirect: (context, state) async {
          final isLoggedIn = await authService.isAuthenticated();
          if (isLoggedIn) {
            return '/home';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/',
        name: 'init',
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const LoginView(),
            ),
        redirect: (context, state) async {
          final isLoggedIn = await authService.isAuthenticated();
          if (isLoggedIn) {
            return '/home';
          }
          return null;
        },
      ),
      ShellRoute(
        pageBuilder:
            (context, state, child) => buildPageWithDefaultTransition<void>(
              context: context,
              state: state,
              child: NavRailPage(child: child),
            ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: DashboardView(),
                ),
            redirect: (context, state) async {
              final isLoggedIn = await authService.isAuthenticated();
              if (!isLoggedIn) {
                return '/login';
              }
              return null;
            },
          ),
          GoRoute(
            path: '/stock',
            name: 'stock',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: StockView(),
                ),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: OrdersView(),
                ),
          ),
          GoRoute(
            path: '/suppliers',
            name: 'suppliers',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: SuppliersView(),
                ),
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: CustomersView(),
                ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: ReportsView(),
                ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: SettingsView(),
                ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder:
                (context, state) => buildPageWithDefaultTransition<void>(
                  context: context,
                  state: state,
                  child: ProfileView(),
                ),
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return FadeTransition(opacity: curvedAnimation, child: child);
    },
  );
}

class NoTransitionPage<T> extends Page<T> {
  final Widget child;

  const NoTransitionPage({required LocalKey key, required this.child})
    : super(key: key);

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute<T>(
      settings: this,
      builder: (BuildContext context) {
        return child;
      },
    );
  }
}
