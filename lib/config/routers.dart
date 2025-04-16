import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/services/auth_service.dart';

import '../data/services/injector/injector_service.dart';

import '../ui/views/home_view.dart';
import '../ui/views/login_view.dart';
import '../ui/views/profile_view.dart';

GoRouter appRouter() {
  final AuthService authService = injector.get<AuthService>();
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
        redirect: (context, state) async {
          // Verifica se o usuário está logado
          final isLoggedIn = await authService.isAuthenticated();
          if (!isLoggedIn) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/profile/:id',
        name: 'profile',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProfileView(userId: id);
        },
      ),
    ],
  );
}

// method go and back route
void goToPath(BuildContext context, String path) {
  GoRouter.of(context).go(path);
}
