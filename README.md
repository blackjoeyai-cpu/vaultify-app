# Vaultify - Password Manager

A secure, offline-first Flutter password vault built with Clean Architecture.

---

## 📊 Development Progress

### ✅ Completed Features

#### Infrastructure
- [x] Clean architecture (4 layers)
- [x] Riverpod state management
- [x] GoRouter navigation
- [x] Hive local storage
- [x] Flutter Secure Storage integration
- [x] Unit tests (auth, vault, encryption, password generator)
- [x] GitHub Actions CI/CD pipeline

#### Authentication
- [x] Login page
- [x] Register page
- [x] Lock page

#### Onboarding
- [x] Onboarding slides (3 pages)
- [x] Welcome page

#### Password Vault
- [x] Vault list page with search
- [x] Category filtering (Social, Financial, Work, Others)
- [x] Add password page
- [x] Password detail page
- [x] Delete password flow
- [x] Password generator UI integration
- [x] Favorite toggle

#### Settings
- [x] Settings page UI
- [x] Auto-lock toggle UI
- [x] Auto-lock toggle implementation
- [x] Clipboard auto-clear setting

#### Security
- [x] Encryption service (AES-256-GCM with PBKDF2)
- [x] Secure clipboard service
- [x] Session persistence across app restarts

---

### ⏳ In Progress

- [ ] Edit password flow
- [ ] Route guards (auth protection)
- [ ] Biometric authentication
- [ ] Auto-lock on app background
- [ ] Password encryption in Hive storage

---

## 🏗️ Architecture

```
Presentation (UI) → Application (Use Cases) → Domain (Entities) → Data (Crypto + Storage)
```

### Layers

| Layer | Description |
|-------|-------------|
| Presentation | UI screens, widgets |
| Application | Providers, state management |
| Domain | Entities, repository interfaces |
| Data | Repository implementations, datasources, crypto |

---

## 🔐 Security

- **Encryption:** AES-256-GCM
- **Key Derivation:** PBKDF2 (100,000 iterations)
- **Storage:** Hive (local) + Flutter Secure Storage (keys)
- **No cloud:** Fully offline-first

---

## 📁 Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── router/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/           # Login, Register, Lock
│   ├── onboarding/     # Onboarding, Welcome
│   ├── vault/         # Password management
│   └── settings/      # App settings
├── shared/
│   ├── services/      # Encryption, Secure Storage
│   └── widgets/       # Shared UI components
└── memory/           # Project memory
```

---

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📝 Notes

- Development progress is tracked in AGENTS.md and README.md
- Memory files: `memory/project_memory.json`, `memory/artifacts.json`
- For detailed specs, see `Doc/` directory