# Vaultify - Password Manager

A secure, offline-first Flutter password vault built with Clean Architecture.

---

## Features

### Authentication
- Master password login and registration
- Biometric authentication support
- Session persistence across app restarts
- Auto-lock on app background

### Password Vault
- Add, view, edit, and delete passwords
- Category filtering (Social, Financial, Work, Others)
- Search functionality
- Favorite toggle
- Built-in password generator
- Password strength indicator

### Security
- AES-256-GCM encryption
- PBKDF2 key derivation (100,000 iterations)
- Secure clipboard with auto-clear
- Encrypted Hive storage
- Route guards for auth protection

### Settings
- Auto-lock timer configuration
- Biometric toggle
- Clipboard auto-clear setting

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

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 📝 Notes

- Development progress is tracked in AGENTS.md and README.md
- Memory files: `memory/project_memory.json`, `memory/artifacts.json`
- For detailed specs, see `Doc/` directory