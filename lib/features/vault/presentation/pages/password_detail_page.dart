import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../application/providers/vault_provider.dart';
import '../../domain/entities/password_entry.dart';

class PasswordDetailPage extends ConsumerStatefulWidget {
  final String id;

  const PasswordDetailPage({super.key, required this.id});

  @override
  ConsumerState<PasswordDetailPage> createState() => _PasswordDetailPageState();
}

class _PasswordDetailPageState extends ConsumerState<PasswordDetailPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultProvider);
    final entry = vaultState.passwords
        .where((p) => p.id == widget.id)
        .firstOrNull;

    if (entry == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: const Text('Password Details')),
        body: const Center(child: Text('Password not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Password Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(entry),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: entry.category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  entry.category.icon,
                  color: entry.category.color,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailTile(
              icon: Icons.person_outline,
              label: 'Username',
              value: entry.username,
            ),
            _buildPasswordTile(label: 'Password', password: entry.password),
            if (entry.url != null && entry.url!.isNotEmpty)
              _buildDetailTile(
                icon: Icons.link,
                label: 'Website',
                value: entry.url!,
              ),
            _buildDetailTile(
              icon: entry.category.icon,
              label: 'Category',
              value: entry.category.displayName,
            ),
            _buildDetailTile(
              icon: Icons.calendar_today_outlined,
              label: 'Created',
              value: entry.createdAt.formatted,
            ),
            _buildDetailTile(
              icon: Icons.update,
              label: 'Last Modified',
              value: entry.updatedAt.formatted,
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty)
              _buildDetailTile(
                icon: Icons.notes,
                label: 'Notes',
                value: entry.notes!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTile({required String label, required String password}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
                ),
                const SizedBox(height: 4),
                Text(
                  _showPassword ? password : '••••••••••••',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppTheme.textSecondary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: password));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Password'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(vaultProvider.notifier).deletePassword(entry.id);
              if (mounted) {
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
