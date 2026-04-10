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
