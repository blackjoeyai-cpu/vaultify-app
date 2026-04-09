# 📁 File Writing Protocol

---

**CRITICAL** - All agents must follow this protocol strictly.

---

## Rules

1. Every file must be explicitly declared before creation
2. No silent file modifications
3. All changes must be atomic
4. No partial edits
5. Always rewrite full file
6. Every change must be reviewed

---

## File Creation

### Required Format

```
path: lib/features/auth/auth_service.dart
purpose: Handles authentication logic
dependencies: crypto module
```

### Content Block

```dart
// full file content here
```

### Example

```
path: lib/features/auth/auth_service.dart
purpose: Handles authentication logic
dependencies: crypto module
```

### CONTENT
```dart
import 'package:vaultify/crypto/encryption_service.dart';

class AuthService {
  final EncryptionService _encryptionService;
  
  AuthService(this._encryptionService);
  
  Future<bool> authenticate(String masterPassword) async {
    // Implementation
  }
}
```

---

## File Update

```
path: lib/features/auth/auth_service.dart
action: MODIFY
reason: Fix encryption handling
```

### Important

Provide **FULL updated file content** (not diff patches)

---

## File Deletion

```
path: lib/old_file.dart
action: DELETE
reason: Deprecated architecture
```

---

## Change Management

- All changes must be reviewed
- Security Agent must re-audit changed security modules
- No hidden state changes
- Every modification is traceable

---

## Atomic Change Principle

All changes must be atomic:
- Complete file rewrite for updates
- Complete file declaration for new files
- Explicit deletion reason for removals
