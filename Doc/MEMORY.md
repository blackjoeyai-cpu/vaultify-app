# 🧠 Memory System

---

Vaultify uses a 3-layer memory system for the multi-agent development process.

---

## 1. Session Memory (Ephemeral)

**Purpose:** Holds current task context

**Characteristics:**
- Reset after feature completion
- Temporary storage during development

**Contains:**
- Current feature being worked on
- Active files being modified
- Pending tasks

---

## 2. Project Memory (Persistent)

**Location:** `/memory/project_memory.json`

**Purpose:** Long-term architectural and security decisions

**Contains:**
- Architecture decisions
- Security decisions
- Module boundaries
- Approved patterns

**Update Rules:**
- Only updated after Security Agent approval
- Versioned for traceability

**Example:**
```json
{
  "architecture": {
    "layers": ["presentation", "application", "domain", "data"],
    "encryption": "AES-256-GCM",
    "keyDerivation": "Argon2id"
  },
  "module_boundaries": {
    "auth": ["login", "register", "biometrics"],
    "vault": ["entries", "categories", "search"]
  }
}
```

---

## 3. Artifact Registry (Persistent)

**Location:** `/memory/artifacts.json`

**Purpose:** Track all generated files and modules

**Contains:**
- Generated files
- Code modules
- Encryption components
- UI components

**Entry Format:**
```json
{
  "id": "auth_module",
  "path": "lib/features/auth",
  "status": "approved",
  "last_updated": "timestamp",
  "version": "1.0.0",
  "dependencies": ["crypto_module"]
}
```

**Status Values:**
- `pending` - Awaiting review
- `approved` - Reviewed and approved
- `deprecated` - No longer in use

---

## Memory Access Pattern

```
Session Memory → Project Memory → Artifact Registry
     ↓
  [Ephemeral]      [Persistent]
```

---

## Update Workflow

1. Session Memory created for each task
2. Approved decisions added to Project Memory
3. New artifacts registered in Artifact Registry
4. Security Agent must approve all updates
