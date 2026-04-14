import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../application/providers/settings_provider.dart';
import '../../../auth/application/providers/auth_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).loadSettings();
    });
  }

  Future<void> _onBiometricToggle(bool value) async {
    if (value) {
      final biometricService = ref.read(biometricServiceProvider);
      final isAvailable = await biometricService.isAvailable();

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometric authentication is not available on this device',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      if (mounted) {
        final confirmed = await _showBiometricSetupDialog();
        if (confirmed == true) {
          ref.read(settingsProvider.notifier).setBiometricEnabled(true);
        }
      }
    } else {
      ref.read(settingsProvider.notifier).setBiometricEnabled(false);
      await ref.read(authProvider.notifier).clearBiometricCredential();
    }
  }

  Future<bool?> _showBiometricSetupDialog() async {
    final passwordController = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Setup Biometric'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your master password to enable biometric unlock.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Master Password',
                hintText: 'Enter your password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              if (password.isEmpty) return;

              final isValid = await ref
                  .read(authProvider.notifier)
                  .verifyPassword(password);

              if (isValid) {
                await ref
                    .read(authProvider.notifier)
                    .saveBiometricCredential(password);
                if (context.mounted) Navigator.of(context).pop(true);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid password'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.lock_clock,
            title: 'Auto-lock',
            subtitle:
                'Lock app after ${settings.autoLockDuration} minutes of inactivity',
            trailing: Switch(
              value: settings.autoLockEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setAutoLockEnabled(value);
              },
            ),
          ),
          if (settings.autoLockEnabled)
            _buildSettingsTile(
              icon: Icons.timer,
              title: 'Auto-lock duration',
              subtitle: '${settings.autoLockDuration} minutes',
              onTap: () => _showDurationPicker(),
            ),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric unlock',
            subtitle: 'Use fingerprint to unlock',
            trailing: Switch(
              value: settings.biometricEnabled,
              onChanged: _onBiometricToggle,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.content_paste_off,
            title: 'Auto-clear clipboard',
            subtitle: 'Clear clipboard 30 seconds after copying',
            trailing: Switch(
              value: settings.clipboardAutoClearEnabled,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .setClipboardAutoClearEnabled(value);
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Danger Zone'),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete all data',
            subtitle: 'This action cannot be undone',
            iconColor: AppTheme.errorColor,
            onTap: () => _showDeleteConfirmation(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = AppTheme.textSecondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: AppTheme.textHint)
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showDurationPicker() {
    final durations = [1, 5, 10, 15, 30];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-lock Duration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...durations.map(
              (duration) => ListTile(
                title: Text('$duration minutes'),
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setAutoLockDuration(duration);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your passwords and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
              context.go(AppRouter.login);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
