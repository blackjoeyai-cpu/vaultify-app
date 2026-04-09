# 🔐 Security Governance

---

Security rules and failure handling for Vaultify development.

---

## Hard Rules

| Rule | Requirement |
|------|-------------|
| Cryptography | **No custom cryptography** |
| Encryption | **AES-256-GCM only** |
| Key Derivation | **Argon2id/PBKDF2 only** |
| Storage | **No plaintext storage ever** |
| Logging | **No logs containing secrets** |

---

## Allowed Cryptography

### Encryption
- Algorithm: AES-256-GCM
- Mode: Authenticated encryption (GCM)
- IV: Randomly generated, unique per encryption

### Key Derivation
- Algorithms: Argon2id (preferred), PBKDF2
- Parameters:
  - Argon2id: memory=65536, iterations=3, parallelism=4
  - PBKDF2: iterations=100000+, SHA-256

---

## Forbidden Patterns

```dart
// ❌ FORBIDDEN - Custom encryption
class MyCipher {
  String encrypt(String data) {
    // DO NOT USE
  }
}

// ❌ FORBIDDEN - Weak encryption
final encrypted = aes_ecb.encrypt(data);

// ❌ FORBIDDEN - Plaintext storage
await storage.write('password', plainText);

// ❌ FORBIDDEN - Secret in logs
print('Password: $password');
```

---

## Security Failure Handling

### If Security Agent Rejects

1. **ALL work on feature pauses**
2. Document all critical issues
3. Fix root cause before continuing
4. Re-submit for security review
5. Cannot proceed without approval

### Escalation Criteria

Escalate to Security Agent if:
- Encryption design is unclear
- Storage safety is uncertain
- Architecture conflicts arise
- Zero-day vulnerabilities suspected

---

## Audit Requirements

- All security modules require Security Agent approval
- Cryptographic changes must be re-audited
- Key handling must be documented
- Attack surface must be minimized

---

## Security Review Checklist

- [ ] AES-256-GCM used correctly
- [ ] Key derivation follows best practices
- [ ] No plaintext secrets
- [ ] Secure memory handling
- [ ] No sensitive data in logs
- [ ] Minimal attack surface
- [ ] Defense in depth implemented
