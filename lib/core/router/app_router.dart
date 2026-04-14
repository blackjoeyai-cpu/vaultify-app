import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/application/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/lock_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/vault/presentation/pages/vault_list_page.dart';
import '../../features/vault/presentation/pages/password_detail_page.dart';
import '../../features/vault/presentation/pages/add_password_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/loading_overlay.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String lock = '/lock';
  static const String vault = '/vault';
  static const String addPassword = '/vault/add';
  static const String editPassword = '/vault/edit/:id';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isInitial = authState.status == AuthStatus.initial;
      final isLoading = authState.status == AuthStatus.loading;

      final currentPath = state.matchedLocation;
      final isOnSplash = currentPath == splash;
      final isOnOnboarding = currentPath == onboarding;
      final isOnWelcome = currentPath == welcome;
      final isOnLogin = currentPath == login;
      final isOnRegister = currentPath == register;
      final isOnLock = currentPath == lock;

      if (isOnSplash || isInitial || isLoading) {
        return null;
      }

      if (!authState.hasMasterPassword && !isOnRegister) {
        if (!isOnOnboarding && !isOnWelcome) {
          return welcome;
        }
        return null;
      }

      if (isOnLock && isAuthenticated) {
        return vault;
      }

      if (!isAuthenticated &&
          !isOnLock &&
          !isOnLogin &&
          !isOnRegister &&
          !isOnOnboarding &&
          !isOnWelcome) {
        return lock;
      }

      if (isAuthenticated && (isOnLogin || isOnRegister)) {
        return vault;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const LoadingOverlay(message: 'Vaultify'),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: welcome, builder: (context, state) => const WelcomePage()),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: lock, builder: (context, state) => const LockPage()),
      GoRoute(path: vault, builder: (context, state) => const VaultListPage()),
      GoRoute(
        path: addPassword,
        builder: (context, state) => const AddPasswordPage(),
      ),
      GoRoute(
        path: editPassword,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddPasswordPage(editId: id);
        },
      ),
      GoRoute(
        path: '/vault/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PasswordDetailPage(id: id);
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
