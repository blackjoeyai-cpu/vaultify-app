# 🤖 AGENTS.md — Vaultify Password Manager (Ultra Advanced)

---

# 🧠 SYSTEM OVERVIEW

Vaultify is a secure, offline-first Flutter password vault using a multi-agent development system.

This file serves as the **index** to agent documentation. For detailed specifications, see the files in the `Doc/` directory.

---

# 📚 DOCUMENTATION INDEX

| Document | Description |
|----------|-------------|
| `Doc/PLANNER.md` | Planner Agent responsibilities and output format |
| `Doc/CODER.md` | Coder Agent responsibilities and file protocol |
| `Doc/REVIEWER.md` | Code review checklist and output format |
| `Doc/SECURITY.md` | Security Agent hard gate rules and audit checklist |
| `Doc/MEMORY.md` | 3-layer memory system (Session, Project, Artifact) |
| `Doc/FILE_PROTOCOL.md` | File creation, update, and deletion protocol |
| `Doc/ARCHITECTURE.md` | 4-layer clean architecture rules |
| `Doc/CORE_PRINCIPLES.md` | Security-first principles |
| `Doc/WORKFLOW.md` | State machine and iteration loop |
| `Doc/SECURITY_GOVERNANCE.md` | Cryptography rules and failure handling |

---

# 🧭 CORE PRINCIPLES

> See: `Doc/CORE_PRINCIPLES.md`

- **Security > functionality**
- No plaintext secrets ever
- Deterministic + auditable changes
- All changes must pass Security Agent
- Everything is traceable (no hidden state)

---

# 🧩 AGENT ROLES

> See: `Doc/PLANNER.md`, `Doc/CODER.md`, `Doc/REVIEWER.md`, `Doc/SECURITY.md`

| Agent | Role | Key Responsibility |
|-------|------|-------------------|
| 🧭 Planner | Task decomposition | Produces implementation plan |
| 👨‍💻 Coder | Implementation | Follows file protocol strictly |
| 🔍 Reviewer | Quality assurance | Ensures architecture compliance |
| 🔐 Security | Final gatekeeper | Validates encryption & security |

---

# 🔁 MULTI-AGENT ITERATION LOOP

> See: `Doc/WORKFLOW.md`

```
INIT → PLANNING → IMPLEMENTING → REVIEWING → SECURITY_CHECK → ACCEPTED
                                                        ↑
                                                   (FIX_LOOP)
```

Every feature MUST follow this loop. Security Agent is a **HARD GATE**.

---

# 🧠 MEMORY SYSTEM

> See: `Doc/MEMORY.md`

| Layer | Type | Location |
|-------|------|----------|
| Session Memory | Ephemeral | Runtime context |
| Project Memory | Persistent | `/memory/project_memory.json` |
| Artifact Registry | Persistent | `/memory/artifacts.json` |

---

# 📁 FILE WRITING PROTOCOL

> See: `Doc/FILE_PROTOCOL.md`

Every file must be:
- Explicitly declared before creation
- Written atomically (full content, not patches)
- Tracked in Artifact Registry

---

# 🏗️ ARCHITECTURE RULES

> See: `Doc/ARCHITECTURE.md`

```
Presentation (UI) → Application (Use Cases) → Domain (Entities) → Data (Crypto + Storage)
```

❌ No skipping layers  
❌ No business logic in UI  

---

# 🔀 GIT COMMIT & PR PROTOCOL

> See: `Doc/CODER.md`

- **ALWAYS** work from `dev` branch for development (create feature branches from dev)
- **NEVER** commit directly to main/master branch
- **ALWAYS** create a separate feature branch for each task/feature
- **ALWAYS** create a pull request for each set of changes
- PR title must be descriptive (1-2 sentences)
- PR body must include:
  - Summary of changes
  - Related issue/ticket (if any)
  - Testing performed
- Wait for code review before merging
- **NEVER** force push to main/master

---

# 🔐 SECURITY GOVERNANCE

> See: `Doc/SECURITY.md`, `Doc/SECURITY_GOVERNANCE.md`

| Rule | Requirement |
|------|-------------|
| Encryption | AES-256-GCM only |
| Key Derivation | Argon2id/PBKDF2 only |
| Storage | No plaintext ever |
| Logging | No secrets in logs |

**If Security Agent rejects:** ALL work pauses until fixed.

---

# 🧾 COMPLETION RULES

A feature is ONLY complete if:
- ✅ Planner approved
- ✅ Code implemented
- ✅ Reviewer approved
- ✅ Security approved
- ✅ All tests pass (`flutter test`)
- ✅ No analysis errors/warnings (`flutter analyze`)

---

# 🧪 TESTING REQUIREMENTS

> All new features and code changes MUST pass tests before merging.

## Test Framework

The project uses `flutter_test` with manual mocks for unit testing.

### Test Structure

```
test/
├── mocks/                    # Mock implementations
│   ├── mock_secure_storage.dart
│   └── mock_hive_box.dart
├── services/                 # Service layer tests
│   └── encryption_service_test.dart
├── repositories/            # Repository layer tests
│   ├── auth_repository_test.dart
│   └── vault_repository_test.dart
└── providers/               # State management tests
    ├── auth_provider_test.dart
    ├── vault_provider_test.dart
    └── password_generator_test.dart
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/providers/vault_provider_test.dart
```

### Code Analysis

```bash
# Check for errors/warnings
flutter analyze
```

### Test Requirements

- **ALL tests must pass** before any PR can be merged
- **No errors or warnings** in `flutter analyze` output
- New features MUST include corresponding unit tests
- Test coverage areas:
  - Authentication flow (master password, session, biometric)
  - Vault CRUD operations (add, update, delete, search, filter)
  - Password generator (generation, strength calculation)
  - Encryption/decryption logic

---

# 📊 DEVELOPMENT PROGRESS

## Features Progress

### Authentication
- [x] Login page
- [x] Register page
- [x] Lock page
- [ ] Route guards (auth protection)

### Onboarding
- [x] Onboarding slides (3 pages)
- [x] Welcome page

### Password Vault
- [x] Vault list page with search
- [x] Category filtering (Social, Financial, Work, Others)
- [x] Add password page
- [x] Password detail page
- [x] Delete password flow
- [x] Password generator UI integration
- [x] Favorite toggle

### Settings
- [x] Settings page UI
- [x] Auto-lock toggle UI
- [x] Auto-lock toggle implementation
- [ ] Auto-lock timer implementation
- [ ] Biometric authentication

### Security
- [x] Encryption service (AES-256-GCM with PBKDF2)
- [x] Secure clipboard service
- [x] Session persistence across app restarts
- [ ] Password encryption in Hive storage
- [ ] Auto-lock on app background

### Infrastructure
- [x] Clean architecture (4 layers)
- [x] Riverpod state management
- [x] GoRouter navigation
- [x] Hive local storage
- [x] Flutter Secure Storage integration
- [x] Memory persistence across app restarts
- [x] Unit tests (auth, vault, encryption, password generator)
- [x] GitHub Actions CI/CD pipeline

---

# 🚨 ESCALATION RULES

Escalate to Security Agent if:
- Encryption design is unclear
- Storage safety is uncertain
- Architecture conflicts arise

---

# 🧠 DESIGN PHILOSOPHY

This system assumes:
- Attackers will reverse engineer the app
- Device storage is compromised
- Memory leaks are exploitable

Therefore:
- Defense in depth is mandatory
- Minimal attack surface is required

---

# 🚀 END GOAL

Deliver a:
- Fully secure
- Offline-first
- Auditable
- Modular password vault system

Built with:
- Flutter
- Strong cryptography
- Clean architecture
