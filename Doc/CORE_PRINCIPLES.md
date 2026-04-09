# 🧭 Core Principles

---

Fundamental principles that govern the Vaultify development system.

---

## Primary Directive

**Security > Functionality**

No feature is worth compromising security.

---

## Core Principles

1. **No plaintext secrets ever**
   - All sensitive data encrypted
   - No secrets in code
   - No secrets in logs

2. **Deterministic + auditable changes**
   - Every change is traceable
   - No hidden state
   - Full audit trail

3. **All changes must pass Security Agent**
   - Security review is mandatory
   - Cannot be bypassed
   - Rejection stops all work

4. **Everything is traceable**
   - No hidden state
   - Complete documentation
   - Artifact registry maintained

---

## Design Philosophy

This system assumes:
- Attackers will reverse engineer the app
- Device storage is compromised
- Memory leaks are exploitable

Therefore:
- **Defense in depth is mandatory**
- **Minimal attack surface is required**

---

## Security Over Functionality

When in doubt:

```
┌─────────────────────────────────┐
│   Security First                │
│   Feature Second               │
│   Convenience Third            │
└─────────────────────────────────┘
```

---

## Compliance

All agents must:
- Follow these principles
- Report violations
- Escalate security concerns
- Maintain audit trail
