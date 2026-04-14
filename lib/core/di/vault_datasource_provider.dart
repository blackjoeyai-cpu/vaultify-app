import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/vault/data/datasources/vault_local_datasource.dart';
import '../../shared/services/encryption_service.dart';
import '../../shared/services/session_provider.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return EncryptionService(secureStorage);
});

VaultLocalDatasource? _datasourceInstance;

Future<void> initializeVaultDatasource() async {
  final encryptionService = EncryptionService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  _datasourceInstance = VaultLocalDatasource(
    encryptionService,
    SessionNotifier(),
  );
  await _datasourceInstance!.init();
}

final vaultLocalDatasourceProvider = Provider<VaultLocalDatasource>((ref) {
  if (_datasourceInstance == null) {
    throw StateError(
      'VaultLocalDatasource not initialized. Call initializeVaultDatasource() first.',
    );
  }
  return _datasourceInstance!;
});
