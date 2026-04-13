import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/application/providers/auth_provider.dart';
import 'features/auth/application/providers/auth_timer_provider.dart';

class VaultifyApp extends ConsumerStatefulWidget {
  const VaultifyApp({super.key});

  @override
  ConsumerState<VaultifyApp> createState() => _VaultifyAppState();
}

class _VaultifyAppState extends ConsumerState<VaultifyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final authTimer = ref.read(authTimerProvider.notifier);
    final authState = ref.read(authProvider);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (authState.status == AuthStatus.authenticated) {
          authTimer.pauseTimer();
        }
        break;
      case AppLifecycleState.resumed:
        if (authState.status == AuthStatus.authenticated) {
          authTimer.resumeTimer();
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Vaultify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
