import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/application/providers/auth_provider.dart';

class VaultifyApp extends ConsumerStatefulWidget {
  const VaultifyApp({super.key});

  @override
  ConsumerState<VaultifyApp> createState() => _VaultifyAppState();
}

class _VaultifyAppState extends ConsumerState<VaultifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'Vaultify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
