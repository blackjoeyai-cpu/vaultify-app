# 📦 Workflow State Machine

---

Multi-agent iteration loop for feature development.

---

## State Diagram

```
┌─────────────┐
│     INIT    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   PLANNING  │ ←──┐
└──────┬──────┘    │
       │           │
       ▼           │
┌─────────────┐    │
│IMPLEMENTING │────┘
└──────┬──────┘  (Fix Loop)
       │
       ▼
┌─────────────┐
│  REVIEWING  │ ←───┐
└──────┬──────┘     │ (Review Failed)
       │           │
       ▼           │
┌─────────────┐    │
│SECURITY_    │────┘
│  CHECK      │  (Security Failed)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  ACCEPTED   │
└─────────────┘
```

---

## States

### INIT
Starting state. Feature request received.

### PLANNING
Planner Agent breaks feature into tasks, identifies dependencies, defines risks.

### IMPLEMENTING
Coder Agent implements assigned tasks following file protocol.

### REVIEWING
Reviewer Agent checks code quality and architecture compliance.

### SECURITY_CHECK
Security Agent validates encryption and security patterns.

### ACCEPTED
Feature complete. All approvals obtained.

### FIX_LOOP
Return to IMPLEMENTING from REVIEWING or SECURITY_CHECK.

---

## State Transitions

| Current State | Event | Next State |
|---------------|-------|------------|
| INIT | Feature request | PLANNING |
| PLANNING | Plan approved | IMPLEMENTING |
| IMPLEMENTING | Code written | REVIEWING |
| REVIEWING | Review passed | SECURITY_CHECK |
| REVIEWING | Review failed | IMPLEMENTING |
| SECURITY_CHECK | Security passed | ACCEPTED |
| SECURITY_CHECK | Security failed | IMPLEMENTING |

---

## Completion Rules

A feature is **ONLY** complete if:

- ✅ Planner approved
- ✅ Code implemented
- ✅ Reviewer approved
- ✅ Security approved

---

## Fix Loop

When rejected by Reviewer or Security Agent:

1. Document issues
2. Return to Coder Agent
3. Fix implementation
4. Re-enter at REVIEWING state
5. Repeat until approved
