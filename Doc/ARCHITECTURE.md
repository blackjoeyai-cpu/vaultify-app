# 🏗️ Architecture Rules

---

Clean Architecture layers for Vaultify password manager.

---

## Layer Structure

```
┌─────────────────────────────────────┐
│     Presentation (UI)               │
├─────────────────────────────────────┤
│     Application (Use Cases)        │
├─────────────────────────────────────┤
│     Domain (Entities)               │
├─────────────────────────────────────┤
│     Data (Crypto + Storage)         │
└─────────────────────────────────────┘
```

---

## 1. Presentation Layer (UI)

**Responsibility:** User interface and presentation logic

**Rules:**
- ❌ No business logic
- ❌ No direct data access
- Only UI components and state management

---

## 2. Application Layer (Use Cases)

**Responsibility:** Application-specific business rules

**Contains:**
- Use cases
- Application services
- DTOs

**Rules:**
- Orchestrates domain entities
- Implements application workflows

---

## 3. Domain Layer (Entities)

**Responsibility:** Core business entities and rules

**Contains:**
- Entities (Password, Category, User)
- Value objects
- Domain services
- Repository interfaces

**Rules:**
- No external dependencies
- Pure Dart/Flutter code

---

## 4. Data Layer (Crypto + Storage)

**Responsibility:** Data persistence and encryption

**Contains:**
- Repository implementations
- Encryption services
- Local storage
- Remote sync (if applicable)

**Security Rules:**
- AES-256-GCM encryption
- Argon2id/PBKDF2 key derivation
- No plaintext storage

---

## Layer Violations

### Forbidden Patterns

```dart
// ❌ BAD - Business logic in UI
class PasswordListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Encryption in UI layer!
    final encrypted = aes.encrypt(password);
    ...
  }
}

// ✅ GOOD - UI only, logic in use case
class PasswordListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: passwords.length,
      itemBuilder: (_, index) => PasswordTile(passwords[index]),
    );
  }
}
```

---

## Module Boundaries

```
lib/
├── core/           # Shared utilities
├── features/
│   ├── auth/       # Authentication
│   ├── vault/      # Password management
│   └── settings/  # App settings
└── shared/         # Cross-cutting concerns
```

---

## Security Requirements

- Defense in depth mandatory
- Minimal attack surface required
- All encryption in Data layer only
