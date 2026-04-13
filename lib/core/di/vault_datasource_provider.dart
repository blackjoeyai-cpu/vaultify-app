import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/vault/data/datasources/vault_local_datasource.dart';

final _datasourceInstance = VaultLocalDatasource();

Future<void> initializeVaultDatasource() async {
  await _datasourceInstance.init();
}

final vaultLocalDatasourceProvider = Provider<VaultLocalDatasource>((ref) {
  return _datasourceInstance;
});
