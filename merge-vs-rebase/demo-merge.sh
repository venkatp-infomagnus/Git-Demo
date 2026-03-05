#!/bin/bash
# =============================================================================
#  demo-merge.sh — Watch a Git merge happen step by step
# =============================================================================
#  Runs right here in the Git-Demo repo. Uses real branches so you can
#  explore afterwards with  git log --oneline --graph --all
#
#  Cleanup: the script deletes the demo branches & files when done (or on Ctrl-C).
# =============================================================================

set -e

# ---- Navigate to repo root --------------------------------------------------
cd "$(git rev-parse --show-toplevel)"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# ---- Cleanup helper (runs on exit or Ctrl-C) --------------------------------
ORIGINAL_BRANCH=$(git branch --show-current)

cleanup() {
  echo ""
  echo -e "${YELLOW}🧹 Cleaning up demo branches & files...${NC}"
  git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
  git branch -D demo/feature-notes 2>/dev/null || true
  git branch -D demo/main 2>/dev/null || true
  rm -f course-notes.txt my-notebook.txt
  echo -e "${GREEN}✅ Cleanup done. Back on branch: $ORIGINAL_BRANCH${NC}"
}
trap cleanup EXIT

# =============================================================================
#  STEP 1 — Set up a demo/main branch (the "official course notes")
# =============================================================================
header "STEP 1 · Create demo/main — the official course notes"

git checkout -b demo/main

echo "Chapter 1: What is Git?" > course-notes.txt
git add course-notes.txt
git commit -m "Add Chapter 1: What is Git?"

echo "Chapter 2: Branching Basics" >> course-notes.txt
git add course-notes.txt
git commit -m "Add Chapter 2: Branching Basics"

echo -e "${GREEN}✅ demo/main now has 2 commits.${NC}"
git --no-pager log --oneline
pause

# =============================================================================
#  STEP 2 — Create your feature branch (your personal notebook)
# =============================================================================
header "STEP 2 · Create demo/feature-notes — your notebook"

git checkout -b demo/feature-notes

echo "Note: Git is awesome!" > my-notebook.txt
git add my-notebook.txt
git commit -m "My note: Git is awesome"

echo "Note: Always commit early & often" >> my-notebook.txt
git add my-notebook.txt
git commit -m "My note: commit early & often"

echo -e "${GREEN}✅ Your notebook branch has 2 new commits.${NC}"
git --no-pager log --oneline
pause

# =============================================================================
#  STEP 3 — Meanwhile the official notes get a new chapter
# =============================================================================
header "STEP 3 · New chapter lands on demo/main while you were writing"

git checkout demo/main

echo "Chapter 3: Merge Strategies" >> course-notes.txt
git add course-notes.txt
git commit -m "Add Chapter 3: Merge Strategies"

echo -e "${GREEN}✅ demo/main now has Chapter 3 — your branch doesn't have it yet.${NC}"
git --no-pager log --oneline
pause

# =============================================================================
#  STEP 4 — BEFORE the merge — look at the graph
# =============================================================================
header "STEP 4 · Graph BEFORE merge"
git --no-pager log --oneline --graph --all --decorate
pause

# =============================================================================
#  STEP 5 — MERGE (combine your notebook with the official notes)
# =============================================================================
header "STEP 5 · git merge demo/feature-notes"
echo ""
echo "  Analogy: Adding a new page that says"
echo "  'I combined my notebook with the latest course notes.'"
echo "  Nothing is rewritten — both histories are preserved."
pause

git merge demo/feature-notes -m "Merge: combine notebook with course notes"

echo ""
echo -e "${GREEN}✅ Merge complete!${NC}"

# =============================================================================
#  STEP 6 — AFTER the merge — look at the result
# =============================================================================
header "STEP 6 · Graph AFTER merge (notice the merge commit)"
git --no-pager log --oneline --graph --all --decorate

echo ""
echo -e "${CYAN}--- course-notes.txt ---${NC}"
cat course-notes.txt
echo ""
echo -e "${CYAN}--- my-notebook.txt ---${NC}"
cat my-notebook.txt
pause

# =============================================================================
#  KEY TAKEAWAYS
# =============================================================================
header "KEY TAKEAWAYS"
echo ""
echo "  1. A merge commit was created — it has TWO parents."
echo "  2. Your original commits are UNTOUCHED (same hashes)."
echo "  3. History shows exactly when branches diverged & joined."
echo "  4. This is ALWAYS safe, even after you pushed your branch."
echo ""
echo -e "${GREEN}  Remember: Merge = 'add a new page'. Nothing rewritten.${NC}"
echo ""
