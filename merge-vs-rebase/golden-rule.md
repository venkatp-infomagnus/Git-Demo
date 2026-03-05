# The Golden Rule of Rebase

## One Rule to Remember

> **If you already shared your notebook, do NOT rewrite pages — merge instead.**

In Git terms:

> **Never rebase a branch that has been pushed to a shared remote.**

---

## Why Does This Rule Exist?

### What rebase does under the hood

When you rebase, Git doesn't actually *move* your commits. It **creates
brand-new copies** with different hashes:

```
BEFORE rebase:
  Your branch:    D (hash: abc123) → E (hash: def456)

AFTER rebase:
  Your branch:    D' (hash: 789xyz) → E' (hash: 012uvw)
```

Same content, **different identity**. The originals (abc123, def456) are gone
from your branch.

### What goes wrong if others have the old commits

```
  You (after rebase):
      main:  A ── B ── C ── D' ── E'    ← new hashes

  Your teammate (still has old commits):
      main:  A ── B ── C
                        \
      feature:           D ── E          ← old hashes

  When teammate pulls → 💥 CHAOS
      Git sees D and D' as DIFFERENT commits (different hashes)
      even though they have the same content.
      Result: duplicated commits, messy conflicts, confused teammates.
```

---

## Safe vs Unsafe Scenarios

### ✅ SAFE to rebase

- You created a branch and **never pushed** it
- You're the **only person** working on the branch (and you know it)
- You're about to push for the **very first time** and want a clean history

### ❌ NEVER rebase

- The branch has been **pushed to origin**
- A teammate has **checked out** or **based work on** your branch
- You've opened a **pull request** (others may have reviewed/fetched it)
- You're on **main** or any shared long-lived branch

---

## What To Do Instead

When you can't rebase, **merge** is always safe:

```bash
# Instead of:  git rebase main        ❌ (if branch is shared)
# Do this:     git merge main          ✅ (always safe)

git checkout feature/my-branch
git merge main
```

This creates a merge commit but **never rewrites existing history**.

---

## Recovery: "I Already Rebased a Shared Branch!"

Don't panic. Here's how to recover:

```bash
# 1. Find the old branch tip in the reflog
git reflog show feature/my-branch

# 2. Reset to the pre-rebase state
git reset --hard feature/my-branch@{1}

# 3. Force-push to restore the original history
#    (Coordinate with your team first!)
git push --force-with-lease origin feature/my-branch
```

Then use **merge** going forward.

---

## TL;DR

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   Pushed?  ──YES──▶  Use MERGE    (safe, always)    │
│      │                                               │
│      NO                                              │
│      │                                               │
│      ▼                                               │
│   Use REBASE  (clean history, local only)            │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

> *"Rebase is rewriting your notes neatly. If someone already photocopied
> your notebook, you can't rewrite the pages — they'll have a different
> version than you. Just add a new page (merge) instead."*
