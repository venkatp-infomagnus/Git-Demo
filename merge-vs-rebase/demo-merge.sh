#!/bin/bash
# =============================================================================
#  demo-merge.sh — Watch a Git merge happen step by step
# =============================================================================
#  This script creates a temporary Git repo, simulates work on main and a
#  feature branch, then merges them — just like combining your notebook
#  with the official course notes.
# =============================================================================

set -e

DEMO_DIR=$(mktemp -d)/merge-demo
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pause() {
  echo ""
  echo -e "${YELLOW}▶ Press Enter to continue...${NC}"
  read -r
}

header() {
  echo ""
  echo "==========================================="
  echo -e "${CYAN}$1${NC}"
  echo "==========================================="
}

# ---- Setup ------------------------------------------------------------------
header "🔧 Setting up a fresh demo repo at $DEMO_DIR"
mkdir -p "$DEMO_DIR" && cd "$DEMO_DIR"
git init
git checkout -b main

echo "Chapter 1: Introduction to Git" > notes.txt
git add notes.txt
git commit -m "Add Chapter 1 (official course notes)"

echo "Chapter 2: Branching Basics" >> notes.txt
git add notes.txt
git commit -m "Add Chapter 2 (official course notes)"

echo -e "${GREEN}✅ main branch now has 2 commits (official course notes).${NC}"
echo ""
echo "--- main branch log ---"
git --no-pager log --oneline
pause

# ---- Create feature branch --------------------------------------------------
header "📓 Creating your feature branch (your notebook)"
git checkout -b feature/my-notes

echo "My Notes: Git is awesome!" >> notes.txt
git add notes.txt
git commit -m "Add personal note: Git is awesome"

echo "My Notes: Always commit early and often" >> notes.txt
git add notes.txt
git commit -m "Add personal note: commit early and often"

echo -e "${GREEN}✅ Your notebook (feature branch) has 2 new commits.${NC}"
echo ""
echo "--- feature branch log ---"
git --no-pager log --oneline
pause

# ---- Meanwhile, main gets updated -------------------------------------------
header "📖 Meanwhile, the official notes get updated on main..."
git checkout main

echo "Chapter 3: Merge Strategies" >> notes.txt
git add notes.txt
git commit -m "Add Chapter 3 (official course notes)"

echo -e "${GREEN}✅ main now has a new Chapter 3 that your branch doesn't have.${NC}"
echo ""
echo "--- main branch log ---"
git --no-pager log --oneline
pause

# ---- Merge ------------------------------------------------------------------
header "🔀 MERGING: Combining your notebook with the official notes"
echo "Running: git merge feature/my-notes"
echo ""
echo "This is like adding a new page to the official notes that says:"
echo "  'I combined my personal notes with the latest course material.'"
echo "  Nothing is rewritten — both histories are preserved."
pause

git merge feature/my-notes -m "Merge feature/my-notes into main"

echo ""
echo -e "${GREEN}✅ Merge complete!${NC}"
echo ""

# ---- Show result ------------------------------------------------------------
header "📊 Final Git log (notice the merge commit)"
git --no-pager log --oneline --graph --all

echo ""
header "📄 Final file contents"
cat notes.txt

echo ""
header "🎯 Key Takeaway"
echo "• A merge commit (M) was created that ties both histories together."
echo "• Your original commits are untouched — nothing was rewritten."
echo "• This is SAFE even if you already shared your branch."
echo ""
echo -e "${CYAN}Demo repo is at: $DEMO_DIR${NC}"
echo "Feel free to explore it with 'git log --oneline --graph --all'"
echo ""
