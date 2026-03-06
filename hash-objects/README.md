# Git Hash Objects — How Git Stores Everything

> **Think of Git as a filing cabinet. Every piece of content gets a unique label
> (a hash). Git uses that label to find, store, and connect everything.**

---

## The Big Picture

When you run `git add` and `git commit`, Git doesn't just "save your files."
Behind the scenes it creates **objects** and labels each one with a **SHA-1 hash**
(a 40-character fingerprint).

There are only **4 types of objects** in Git's filing cabinet:

```
┌─────────────────────────────────────────────────────────┐
│                    Git Object Types                     │
├──────────┬──────────────────────────────────────────────┤
│  blob    │  The actual file contents (no filename!)     │
│  tree    │  A directory listing — maps names → blobs    │
│  commit  │  A snapshot — points to a tree + metadata    │
│  tag     │  A named label pointing to a commit          │
└──────────┴──────────────────────────────────────────────┘
```

---

## Analogy: The Library 📚

| Git Concept | Library Analogy |
|---|---|
| **blob** | A single page of text (no title on the page itself) |
| **tree** | The table of contents — lists page titles → page locations |
| **commit** | A dated library card: "On March 6, these pages were filed" |
| **hash (SHA-1)** | The barcode on every item — unique, never duplicated |

---

## What Is a Hash?

A hash is a **fingerprint** of content. Same content → same hash. Always.

```
"Hello World" → sha1 → 557db03de997c86a4a028e1ebd3a1ceb225be238
"Hello World" → sha1 → 557db03de997c86a4a028e1ebd3a1ceb225be238   (same!)
"Hello World!" → sha1 → 33ab5639bfd8e7b95eb1d8d0b87781d4ffea4d5d  (different!)
```

Key properties:
- **Deterministic** — same input always gives the same output
- **Unique** — even a tiny change produces a completely different hash
- **One-way** — you can't reverse a hash to get the original content

---

## The 4 Object Types Explained

### 1. Blob (Binary Large Object)

A blob is just **raw file contents**. No filename, no permissions — just the bytes.

```bash
# Create a blob manually:
echo "Hello Git" | git hash-object --stdin
# → prints a 40-char hash like: 9f4d96d5b00d98959ea9960f069585ce42b1349a

# Store it in Git's database:
echo "Hello Git" | git hash-object -w --stdin
# → same hash, but now saved in .git/objects/
```

Two files with identical content share the **same blob** — Git never stores
duplicates!

### 2. Tree

A tree is like a **directory listing**. It maps filenames to blobs (and
subdirectories to other trees).

```
tree 8a3f...
├── README.md  → blob abc1...
├── app.js     → blob def2...
└── src/       → tree 789e...
```

```bash
# See the tree of the latest commit:
git cat-file -p HEAD^{tree}
```

### 3. Commit

A commit ties everything together:

```
commit e4f8...
├── tree     → 8a3f...    (which files/folders)
├── parent   → b2c1...    (previous commit)
├── author   → Alice <alice@example.com>
├── date     → 2026-03-06
└── message  → "Add login feature"
```

```bash
# Inspect a commit:
git cat-file -p HEAD
```

### 4. Tag (annotated)

A tag is a **named pointer** to a commit, with optional metadata:

```bash
git tag -a v1.0 -m "First release"
git cat-file -p v1.0
```

---

## How They Connect

```
                    ┌──────────┐
                    │  commit  │
                    │  e4f8... │
                    └────┬─────┘
                         │ points to
                    ┌────▼─────┐
                    │   tree   │
                    │  8a3f... │
                    └────┬─────┘
                    ┌────┴──────────┐
               ┌────▼─────┐   ┌────▼─────┐
               │   blob   │   │   tree   │
               │  abc1... │   │  789e... │
               │ README   │   │  src/    │
               └──────────┘   └────┬─────┘
                              ┌────▼─────┐
                              │   blob   │
                              │  def2... │
                              │  app.js  │
                              └──────────┘
```

Every commit → points to a tree → which points to blobs and more trees.  
It's **objects all the way down.**

---

## Useful Commands

| Command | What it does |
|---|---|
| `git hash-object <file>` | Compute the hash of a file (don't store it) |
| `git hash-object -w <file>` | Compute hash AND store the blob |
| `git cat-file -t <hash>` | Show the **type** of an object (blob/tree/commit/tag) |
| `git cat-file -p <hash>` | **Pretty-print** the contents of an object |
| `git cat-file -s <hash>` | Show the **size** (in bytes) of an object |
| `git ls-tree HEAD` | List files in the latest commit's tree |
| `git rev-parse HEAD` | Show the full hash of HEAD |

---

## Run the Demo

```bash
bash demo-hash-objects.sh
```

The demo script walks you through each concept interactively, right here in
this repository.

---

## TL;DR

```
 You type:    git add README.md  →  Git creates a BLOB (file contents)
 You type:    git commit          →  Git creates a TREE (directory listing)
                                      + a COMMIT (snapshot + metadata)
 Everything gets a SHA-1 HASH — a unique 40-char fingerprint.
 Same content = same hash. Always.
```
