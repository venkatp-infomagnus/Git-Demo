#!/bin/bash
# =============================================================================
#  demo-rebase.sh — Watch a Git rebase happen step by step
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

echo "Note: Rebase keeps history linear!" > my-notebook.txt
git add my-notebook.txt
git commit -m "My note: rebase keeps history linear"

echo "Note: Only rebase local branches" >> my-notebook.txt
git add my-notebook.txt
git commit -m "My note: only rebase local branches"

echo -e "${GREEN}✅ Your notebook branch has 2 new commits.${NC}"
git --no-pager log --oneline

echo ""
echo -e "${YELLOW}📌 Remember these commit hashes — they will CHANGE after rebase!${NC}"
BEFORE_HASHES=$(git --no-pager log --oneline demo/feature-notes ^demo/main)
echo "$BEFORE_HASHES"
pause

# =============================================================================
#  STEP 3 — Meanwhile the official notes get a new chapter
# =============================================================================
header "STEP 3 · New chapter lands on demo/main while you were writing"

git checkout demo/main

echo "Chapter 3: Rebase Deep Dive" >> course-notes.txt
git add course-notes.txt
git commit -m "Add Chapter 3: Rebase Deep Dive"

echo -e "${GREEN}✅ demo/main now has Chapter 3 — your branch doesn't have it yet.${NC}"
git --no-pager log --oneline
pause

# =============================================================================
#  STEP 4 — BEFORE the rebase — look at the graph
# =============================================================================
header "STEP 4 · Graph BEFORE rebase"
git --no-pager log --oneline --graph --all --decorate
pause

# =============================================================================
#  STEP 5 — REBASE (rewrite your notebook on top of the latest notes)
# =============================================================================
header "STEP 5 · git rebase demo/main"
echo ""
echo "  Analogy: Rewriting your notebook pages neatly so it LOOKS like"
echo "  you started taking notes AFTER Chapter 3 was already published."
echo "  Your ideas stay the same, but the pages are brand-new copies."
pause

git checkout demo/feature-notes
git rebase demo/main

echo ""
echo -e "${GREEN}✅ Rebase complete!${NC}"
pause

# =============================================================================
#  STEP 6 — AFTER the rebase — look at the result
# =============================================================================
header "STEP 6 · Graph AFTER rebase (notice the linear history)"
git --no-pager log --oneline --graph --all --decorate

echo ""
header "🔍 Compare commit hashes — BEFORE vs AFTER"
echo ""
echo "BEFORE rebase (old hashes — these no longer exist):"
echo -e "${RED}$BEFORE_HASHES${NC}"
echo ""
echo "AFTER rebase (new hashes — rewritten copies):"
AFTER_HASHES=$(git --no-pager log --oneline demo/feature-notes ^demo/main)
echo -e "${GREEN}$AFTER_HASHES${NC}"
echo ""
echo -e "${YELLOW}⚠️  Same messages, DIFFERENT hashes — this is 'rewriting history'.${NC}"

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
echo "  1. Rebase replayed your commits ON TOP of the latest demo/main."
echo "  2. History is now LINEAR — no merge commit needed."
echo "  3. But commit hashes CHANGED (D → D', E → E')."
echo ""
echo -e "${RED}  ⚠️  THE GOLDEN RULE:${NC}"
echo -e "${RED}  If you already pushed/shared your branch, do NOT rebase!${NC}"
echo -e "${RED}  Others have the OLD hashes. Rewriting will cause conflicts.${NC}"
echo -e "${RED}  Use MERGE instead — it's always safe.${NC}"
echo ""
echo -e "${GREEN}  Remember: Rebase = 'rewrite your notes neatly'. History changes.${NC}"
echo ""
