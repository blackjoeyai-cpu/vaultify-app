import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/password_entry.dart';
import '../../domain/repositories/vault_repository.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../data/datasources/vault_local_datasource.dart';
import '../../../auth/application/providers/auth_provider.dart';

final vaultLocalDatasourceProvider = Provider<VaultLocalDatasource>((ref) {
  return VaultLocalDatasource();
});

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final localDatasource = ref.watch(vaultLocalDatasourceProvider);
  return VaultRepositoryImpl(localDatasource);
});

class VaultState {
  final List<PasswordEntry> passwords;
  final bool isLoading;
  final String? error;
  final PasswordCategory? selectedCategory;
  final String searchQuery;

  const VaultState({
    this.passwords = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });

  VaultState copyWith({
    List<PasswordEntry>? passwords,
    bool? isLoading,
    String? error,
    PasswordCategory? selectedCategory,
    String? searchQuery,
    bool clearCategory = false,
  }) {
    return VaultState(
      passwords: passwords ?? this.passwords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<PasswordEntry> get filteredPasswords {
    var filtered = passwords;

    if (selectedCategory != null) {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.username.toLowerCase().contains(query) ||
            (p.url?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repository;

  VaultNotifier(this._repository) : super(const VaultState());

  Future<void> loadPasswords() async {
    state = state.copyWith(isLoading: true);
    try {
      final passwords = await _repository.getAllPasswords();
      state = state.copyWith(passwords: passwords, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addPassword(PasswordEntry entry) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.savePassword(entry);
      await loadPasswords();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updatePassword(entry);
      await loadPasswords();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePassword(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deletePassword(id);
      await loadPasswords();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(PasswordCategory? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = state.copyWith(clearCategory: true, searchQuery: '');
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  final repository = ref.watch(vaultRepositoryProvider);
  return VaultNotifier(repository);
});

final selectedPasswordProvider = FutureProvider.family<PasswordEntry?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(vaultRepositoryProvider);
  return repository.getPasswordById(id);
});
