# Git Merge vs Rebase — The Notebook Analogy 📒

> **Your feature branch is your notebook; `main` is the official course notes.**

This guide uses a simple analogy to help you understand two of Git's most
confusing operations: **merge** and **rebase**.

---

## The Analogy

Imagine you're taking a class:

| Git Concept       | Notebook Analogy                                    |
| ----------------- | --------------------------------------------------- |
| `main` branch     | The **official course notes** everyone shares        |
| feature branch    | **Your personal notebook** where you draft ideas     |
| `git merge`       | Adding a new page: _"I combined my notes with the latest official notes"_ — nothing rewritten |
| `git rebase`      | Rewriting your notes neatly so it **looks like you started from the latest official notes** |

---

## Merge — "Add a new page"

```
main:     A --- B --- C
                       \
feature:                D --- E        ← your notes

After merge:

main:     A --- B --- C ---------- M   ← merge commit (new page)
                       \         /
feature:                D --- E
```

- Your history is **preserved exactly as it happened**.
- A new "merge commit" (M) ties the two histories together.
- Safe to use **anytime**, even after you've shared your branch.

### Try it yourself

```bash
cd merge-vs-rebase
bash demo-merge.sh
```

---

## Rebase — "Rewrite your notes neatly"

```
main:     A --- B --- C
                       \
feature:                D --- E        ← your notes

After rebase:

main:     A --- B --- C
                       \
feature:                D' --- E'      ← rewritten on top of C
```

- Your commits are **replayed** on top of the latest `main`.
- The history looks clean and linear — as if you started fresh.
- **Rewrites history** (D → D', E → E'), so commit hashes change.

### Try it yourself

```bash
cd merge-vs-rebase
bash demo-rebase.sh
```

---

## The Golden Rule ⚠️

> **If you already shared your notebook, do NOT rewrite pages — merge instead.**

| Situation | Use |
| --- | --- |
| Branch is **local only** (not pushed) | ✅ Rebase is fine |
| Branch is **pushed / shared** with others | ✅ Merge (safe) |
| Branch is **pushed / shared** with others | ❌ **Never** rebase |

Why? Because rebase rewrites commit hashes. If someone else already has your
old commits, their history will **conflict** with yours — causing chaos.

---

## Quick Reference

| | Merge | Rebase |
|---|---|---|
| History | Non-linear (shows branches) | Linear (clean line) |
| Commits | Adds a merge commit | Rewrites your commits |
| Safe after push? | ✅ Yes | ❌ No |
| When to use | Shared branches, PRs | Local cleanup before push |

---

## Files in this demo

| File | Purpose |
| --- | --- |
| `demo-merge.sh` | Hands-on script: walks you through a real merge |
| `demo-rebase.sh` | Hands-on script: walks you through a real rebase |
| `cheatsheet.md` | One-page visual cheatsheet to keep at your desk |
| `golden-rule.md` | The one rule you must never break |

---

_Happy learning! Run the demo scripts and watch how your Git log changes._ 🚀
