# Merge vs Rebase — Visual Cheatsheet

> Print this out and keep it at your desk!

---

## The Notebook Analogy

```
 YOUR NOTEBOOK (feature branch)          OFFICIAL NOTES (main)
 ┌──────────────────────────┐            ┌──────────────────────────┐
 │  📝 My idea about X      │            │  📖 Chapter 1             │
 │  📝 My idea about Y      │            │  📖 Chapter 2             │
 │                          │            │  📖 Chapter 3 (NEW!)      │
 └──────────────────────────┘            └──────────────────────────┘
```

---

## Option A: MERGE — "Add a new page"

```
 BEFORE                              AFTER MERGE
 
 main:  A ── B ── C                  main:  A ── B ── C ────────── M
                   \                                    \         /
 feature:           D ── E           feature:            D ── E
 
                                     M = merge commit ("new page")
                                     D and E are UNCHANGED ✅
```

**What happened:**
- Git created a new "merge commit" (M) that has two parents
- Your original commits (D, E) keep their original hashes
- History shows exactly when the branches diverged and joined

**When to use:** ALWAYS safe. Especially when branch is shared/pushed.

---

## Option B: REBASE — "Rewrite your notes neatly"

```
 BEFORE                              AFTER REBASE
 
 main:  A ── B ── C                  main:  A ── B ── C
                   \                                    \
 feature:           D ── E           feature:            D' ── E'
 
                                     D' and E' are NEW copies ⚠️
                                     (same content, different hashes)
```

**What happened:**
- Git "replayed" your commits on top of the latest main
- D became D' and E became E' (new hashes!)
- History looks linear and clean — no merge commit

**When to use:** ONLY when branch is local (not pushed/shared).

---

## Decision Flowchart

```
    Have you pushed / shared this branch?
                    │
           ┌───────┴────────┐
           │                 │
          YES               NO
           │                 │
      ┌────┴────┐      ┌────┴────┐
      │  MERGE  │      │ Either  │
      │ (safe!) │      │ is fine │
      └─────────┘      └────┬────┘
                             │
                    Want clean history?
                        │
               ┌────────┴────────┐
               │                  │
              YES                NO
               │                  │
          ┌────┴────┐       ┌────┴────┐
          │ REBASE  │       │  MERGE  │
          └─────────┘       └─────────┘
```

---

## Commands at a Glance

```bash
# ---- MERGE ----
git checkout main
git merge feature/my-branch          # Creates merge commit

# ---- REBASE ----
git checkout feature/my-branch
git rebase main                      # Replays commits on top of main
# Then, after rebase:
git checkout main
git merge feature/my-branch          # This is now a fast-forward!
```

---

## Remember

| | Merge | Rebase |
|---|---|---|
| Creates new commit? | Yes (merge commit) | No |
| Rewrites history? | **No** ✅ | **Yes** ⚠️ |
| Safe after push? | **Yes** ✅ | **No** ❌ |
| History shape | Branching / non-linear | Clean / linear |
| Analogy | Add a new page combining notes | Rewrite your notes from scratch |

---

> **THE GOLDEN RULE:**
> If you already shared your notebook, **do NOT rewrite pages** — merge instead.
