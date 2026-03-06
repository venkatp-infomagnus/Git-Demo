# Git Internals — Quick Reference Card

> Print this and keep it handy!

---

## The 4 Object Types

```
┌────────────┬──────────────────────────────────────────────┐
│  BLOB      │  Raw file contents. No name, no metadata.    │
│            │  Same content = same blob (deduplicated).     │
├────────────┼──────────────────────────────────────────────┤
│  TREE      │  Directory listing.                          │
│            │  Maps: filename → blob, dirname → tree.      │
├────────────┼──────────────────────────────────────────────┤
│  COMMIT    │  Snapshot. Points to a tree + parent commit. │
│            │  Stores: author, date, message.              │
├────────────┼──────────────────────────────────────────────┤
│  TAG       │  Named pointer to a commit + annotation.     │
│            │  (Annotated tags only; lightweight = ref.)    │
└────────────┴──────────────────────────────────────────────┘
```

---

## How Objects Connect

```
  tag v1.0 ──▶ commit a1b2 ──▶ tree c3d4 ──▶ blob e5f6 (README.md)
                  │                  └──▶ tree g7h8 (src/)
                  │                          └──▶ blob i9j0 (app.js)
                  ▼
              commit (parent)
```

---

## Hash = Fingerprint

```
  content  ──▶  SHA-1 function  ──▶  40-char hex string
  "Hello"       (one-way)           "ce013625030ba8dba906f756967f9e9ca394464a"
```

- Same content → **same hash** (always)
- Change 1 byte → **completely different hash**
- Can't reverse hash → content

---

## Essential Commands

```bash
# ── Compute & Store ──────────────────────────────────────
git hash-object <file>           # Compute hash (don't store)
git hash-object -w <file>        # Compute hash AND store blob
echo "text" | git hash-object --stdin      # Hash from stdin

# ── Inspect Objects ──────────────────────────────────────
git cat-file -t <hash>           # Type  (blob/tree/commit/tag)
git cat-file -p <hash>           # Pretty-print contents
git cat-file -s <hash>           # Size in bytes

# ── Browse Trees ─────────────────────────────────────────
git ls-tree HEAD                 # Files in latest commit
git ls-tree -r HEAD              # Files (recursive)
git ls-tree HEAD src/            # Files inside src/

# ── Resolve References ───────────────────────────────────
git rev-parse HEAD               # Full hash of HEAD
git rev-parse HEAD~1             # Full hash of parent commit
git rev-parse main               # Full hash of branch tip
```

---

## Where Objects Live on Disk

```
.git/objects/
├── ab/
│   └── cdef1234...    ← object with hash abcdef1234...
├── ff/
│   └── 012345ab...    ← object with hash ff012345ab...
├── info/
└── pack/              ← packed objects (for efficiency)
```

First 2 chars = folder name. Remaining 38 = filename.

---

## Mental Model

```
  git add README.md
    └──▶ creates BLOB (file contents → hash)

  git commit -m "msg"
    ├──▶ creates TREE  (directory snapshot → hash)
    └──▶ creates COMMIT (tree + parent + author + msg → hash)

  Every operation = creating hash-addressed objects.
  That's all Git is.
```
