#!/bin/bash
# =============================================================================
#  demo-hash-objects.sh — Explore Git's internals step by step
# =============================================================================
#  Runs right here in the Git-Demo repo. Shows how blobs, trees, and commits
#  are just hash-addressed objects in Git's filing cabinet.
#
#  Nothing is pushed. Cleanup happens automatically on exit.
# =============================================================================

set -e

# ---- Navigate to repo root --------------------------------------------------
cd "$(git rev-parse --show-toplevel)"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

pause() {
  echo ""
  echo -e "${YELLOW}▶  Press Enter to continue...${NC}"
  read -r
}

header() {
  echo ""
  echo "==========================================="
  echo -e "${CYAN}$1${NC}"
  echo "==========================================="
}

# ---- Cleanup helper ---------------------------------------------------------
cleanup() {
  echo ""
  echo -e "${YELLOW}🧹 Cleaning up demo files...${NC}"
  rm -f demo-hello.txt demo-goodbye.txt demo-hello-copy.txt
  echo -e "${GREEN}✅ Cleanup done.${NC}"
}
trap cleanup EXIT

# =============================================================================
#  STEP 1 — What is a hash?
# =============================================================================
header "STEP 1 · What is a hash?"

echo ""
echo "  A hash is a FINGERPRINT of content."
echo "  Same content → same hash. Every time."
echo ""
echo "  Let's prove it. We'll hash the string 'Hello Git' twice:"
echo ""

HASH1=$(echo "Hello Git" | git hash-object --stdin)
HASH2=$(echo "Hello Git" | git hash-object --stdin)

echo -e "  echo \"Hello Git\" | git hash-object --stdin"
echo -e "  → ${GREEN}$HASH1${NC}"
echo ""
echo -e "  echo \"Hello Git\" | git hash-object --stdin  (again)"
echo -e "  → ${GREEN}$HASH2${NC}"
echo ""

if [ "$HASH1" = "$HASH2" ]; then
  echo -e "  ${GREEN}✅ Identical! Same content always gives the same hash.${NC}"
else
  echo -e "  ${RED}❌ Something went wrong — these should match!${NC}"
fi

echo ""
echo "  Now let's change just ONE character — 'Hello Git!' (added !):"
echo ""

HASH3=$(echo "Hello Git!" | git hash-object --stdin)
echo -e "  echo \"Hello Git!\" | git hash-object --stdin"
echo -e "  → ${RED}$HASH3${NC}"
echo ""
echo -e "  ${YELLOW}⚠️  Completely different hash! Even a tiny change = new fingerprint.${NC}"
pause

# =============================================================================
#  STEP 2 — Blobs: storing file contents
# =============================================================================
header "STEP 2 · Blobs — raw file contents"

echo ""
echo "  A blob is just raw file contents. No filename, no metadata."
echo "  Let's create a file and store it as a blob:"
echo ""

echo "Hello from the demo!" > demo-hello.txt
BLOB_HASH=$(git hash-object -w demo-hello.txt)

echo "  echo 'Hello from the demo!' > demo-hello.txt"
echo -e "  git hash-object -w demo-hello.txt"
echo -e "  → blob hash: ${GREEN}$BLOB_HASH${NC}"
echo ""
echo "  The '-w' flag means WRITE — Git saved it in .git/objects/"
echo ""

# Show where it lives
DIR=${BLOB_HASH:0:2}
FILE=${BLOB_HASH:2}
echo -e "  Stored at: ${CYAN}.git/objects/$DIR/$FILE${NC}"
echo ""

echo "  Let's verify — ask Git what type this object is:"
TYPE=$(git cat-file -t "$BLOB_HASH")
SIZE=$(git cat-file -s "$BLOB_HASH")
echo -e "  git cat-file -t $BLOB_HASH → ${GREEN}$TYPE${NC}"
echo -e "  git cat-file -s $BLOB_HASH → ${GREEN}$SIZE bytes${NC}"
echo ""

echo "  And read the content back out:"
CONTENT=$(git cat-file -p "$BLOB_HASH")
echo -e "  git cat-file -p $BLOB_HASH → ${GREEN}$CONTENT${NC}"
pause

# =============================================================================
#  STEP 3 — Same content = same blob (deduplication)
# =============================================================================
header "STEP 3 · Same content = same blob (deduplication)"

echo ""
echo "  What if two files have IDENTICAL content?"
echo ""

cp demo-hello.txt demo-hello-copy.txt
BLOB_COPY=$(git hash-object demo-hello-copy.txt)

echo "  cp demo-hello.txt demo-hello-copy.txt"
echo -e "  git hash-object demo-hello-copy.txt → ${GREEN}$BLOB_COPY${NC}"
echo ""

if [ "$BLOB_HASH" = "$BLOB_COPY" ]; then
  echo -e "  ${GREEN}✅ Same hash! Git only stores ONE copy of the content.${NC}"
  echo "  Two filenames, one blob. Git never wastes space on duplicates."
else
  echo -e "  ${RED}Hashes differ — unexpected!${NC}"
fi
pause

# =============================================================================
#  STEP 4 — Trees: directory listings
# =============================================================================
header "STEP 4 · Trees — directory listings"

echo ""
echo "  Blobs have no filenames. A TREE maps names → blobs."
echo "  Think of it as a table of contents."
echo ""
echo "  Let's look at the tree from the latest commit (HEAD):"
echo ""
echo -e "  ${BOLD}git ls-tree HEAD${NC}"
echo ""
git ls-tree HEAD | while read -r mode type hash name; do
  echo -e "  $mode ${CYAN}$type${NC} $hash  ${GREEN}$name${NC}"
done

echo ""
echo "  Each line says: permissions, object-type, hash, filename."
echo "  'blob' = file contents.  'tree' = subdirectory."
pause

# =============================================================================
#  STEP 5 — Commits: snapshots with metadata
# =============================================================================
header "STEP 5 · Commits — snapshots + metadata"

echo ""
echo "  A commit is a snapshot that points to a tree + adds metadata."
echo "  Let's inspect HEAD:"
echo ""

COMMIT_HASH=$(git rev-parse HEAD)
echo -e "  Commit hash: ${GREEN}$COMMIT_HASH${NC}"
echo ""
echo -e "  ${BOLD}git cat-file -p HEAD${NC}"
echo ""
git cat-file -p HEAD | while IFS= read -r line; do
  echo "  $line"
done

echo ""
echo "  ↑ Notice:"
echo "    • 'tree'    → points to the root directory listing"
echo "    • 'parent'  → points to the previous commit (the chain!)"
echo "    • 'author'  → who wrote it"
echo "    • message   → what changed"
pause

# =============================================================================
#  STEP 6 — The object chain: commit → tree → blob
# =============================================================================
header "STEP 6 · The chain: commit → tree → blob"

echo ""
echo "  Let's follow the chain from commit to actual file contents:"
echo ""

TREE_HASH=$(git cat-file -p HEAD | grep '^tree' | awk '{print $2}')
echo -e "  1. Commit ${GREEN}${COMMIT_HASH:0:7}${NC} → tree ${GREEN}${TREE_HASH:0:7}${NC}"
echo ""

echo "  2. Tree ${GREEN}${TREE_HASH:0:7}${NC} contains:"
git ls-tree "$TREE_HASH" | head -5 | while read -r mode type hash name; do
  echo -e "     ${CYAN}$type${NC} ${GREEN}${hash:0:7}${NC}  $name"

  # If it's a blob, show a preview of its content
  if [ "$type" = "blob" ]; then
    PREVIEW=$(git cat-file -p "$hash" | head -1)
    echo -e "       ↳ content: ${YELLOW}$PREVIEW${NC}"
  fi
done

echo ""
echo -e "  ${GREEN}✅ That's the full chain: commit → tree → blobs${NC}"
echo "  Everything in Git is just objects pointing to other objects."
pause

# =============================================================================
#  STEP 7 — Bonus: hash a new blob manually and find it in .git/objects
# =============================================================================
header "STEP 7 · Bonus: peek inside .git/objects"

echo ""
echo "  Git stores objects in .git/objects/ using the first 2 chars"
echo "  of the hash as a folder name, and the remaining 38 as the file."
echo ""

echo "Goodbye from the demo!" > demo-goodbye.txt
NEW_HASH=$(git hash-object -w demo-goodbye.txt)
NEW_DIR=${NEW_HASH:0:2}
NEW_FILE=${NEW_HASH:2}

echo -e "  New blob hash: ${GREEN}$NEW_HASH${NC}"
echo -e "  Stored at:     ${CYAN}.git/objects/$NEW_DIR/$NEW_FILE${NC}"
echo ""

if [ -f ".git/objects/$NEW_DIR/$NEW_FILE" ]; then
  echo -e "  ${GREEN}✅ File exists! Git's filing cabinet at work.${NC}"
  FILE_SIZE=$(wc -c < ".git/objects/$NEW_DIR/$NEW_FILE" | tr -d ' ')
  echo -e "  Compressed size on disk: ${YELLOW}${FILE_SIZE} bytes${NC}"
  echo "  (Git compresses objects with zlib — that's why it's so efficient!)"
else
  echo -e "  ${RED}File not found — unexpected.${NC}"
fi
pause

# =============================================================================
#  KEY TAKEAWAYS
# =============================================================================
header "KEY TAKEAWAYS"
echo ""
echo "  1. Everything in Git is a hash-addressed OBJECT."
echo "  2. BLOB  = raw file contents (no filename)."
echo "  3. TREE  = directory listing (maps filenames → blobs)."
echo "  4. COMMIT = snapshot (points to tree + parent + metadata)."
echo "  5. Same content → same hash → ONE copy (deduplication)."
echo "  6. Objects live in .git/objects/<first-2-chars>/<rest>."
echo ""
echo "  Useful commands to remember:"
echo "    git hash-object <file>       Compute a file's hash"
echo "    git cat-file -t <hash>       Show object type"
echo "    git cat-file -p <hash>       Pretty-print object"
echo "    git ls-tree HEAD             List files in latest tree"
echo ""
echo -e "${GREEN}  Git's internals aren't magic — just objects & hashes!${NC}"
echo ""
