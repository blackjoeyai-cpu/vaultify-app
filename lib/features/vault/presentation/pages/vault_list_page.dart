import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../application/providers/vault_provider.dart';
import '../../domain/entities/password_entry.dart';
import '../widgets/password_card.dart';
import '../widgets/category_chip.dart';

class VaultListPage extends ConsumerStatefulWidget {
  const VaultListPage({super.key});

  @override
  ConsumerState<VaultListPage> createState() => _VaultListPageState();
}

class _VaultListPageState extends ConsumerState<VaultListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaultProvider.notifier).loadPasswords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(vaultProvider.notifier).setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search passwords...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(vaultProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: PasswordCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    category: category,
                    isSelected: vaultState.selectedCategory == category,
                    onTap: () {
                      ref.read(vaultProvider.notifier).setCategory(category);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vaultState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vaultState.filteredPasswords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vaultState.filteredPasswords.length,
                    itemBuilder: (context, index) {
                      final entry = vaultState.filteredPasswords[index];
                      return PasswordCard(
                        entry: entry,
                        onTap: () => context.push('/vault/${entry.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.addPassword),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 50,
              color: AppTheme.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No passwords yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first password',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
