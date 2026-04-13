import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/application/providers/auth_provider.dart';
import '../../features/settings/application/providers/settings_provider.dart';

class LoadingOverlay extends ConsumerStatefulWidget {
  final String message;

  const LoadingOverlay({super.key, required this.message});

  @override
  ConsumerState<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends ConsumerState<LoadingOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    await ref.read(authProvider.notifier).checkAuthStatus();
    await ref.read(settingsProvider.notifier).loadSettings();

    if (!mounted) return;

    final authState = ref.read(authProvider);
    final settings = ref.read(settingsProvider);

    if (!authState.hasMasterPassword) {
      context.go('/register');
    } else if (authState.status == AuthStatus.authenticated &&
        settings.autoLockEnabled) {
      context.go('/vault');
    } else {
      context.go('/lock');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 1500.ms,
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
            const SizedBox(height: 32),
            Text(
              widget.message,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.surfaceColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
