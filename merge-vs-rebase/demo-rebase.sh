#!/bin/bash
# =============================================================================
#  demo-rebase.sh — Watch a Git rebase happen step by step
# =============================================================================
#  This script creates a temporary Git repo, simulates work on main and a
#  feature branch, then rebases — like rewriting your notebook pages neatly
#  so it looks like you started from the latest official notes.
# =============================================================================

set -e

DEMO_DIR=$(mktemp -d)/rebase-demo
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

echo "My Notes: Rebase keeps history linear!" > my-notes.txt
git add my-notes.txt
git commit -m "Add personal note: rebase keeps history linear"

echo "My Notes: Use rebase only on local branches" >> my-notes.txt
git add my-notes.txt
git commit -m "Add personal note: only rebase local branches"

echo -e "${GREEN}✅ Your notebook (feature branch) has 2 new commits.${NC}"
echo ""
echo "--- feature branch log ---"
git --no-pager log --oneline

echo ""
echo -e "${YELLOW}📌 Remember these commit hashes — they will CHANGE after rebase!${NC}"
BEFORE_HASHES=$(git --no-pager log --oneline feature/my-notes ^main)
echo "$BEFORE_HASHES"
pause

# ---- Meanwhile, main gets updated -------------------------------------------
header "📖 Meanwhile, the official notes get updated on main..."
git checkout main

echo "Chapter 3: Rebase Deep Dive" >> notes.txt
git add notes.txt
git commit -m "Add Chapter 3 (official course notes)"

echo -e "${GREEN}✅ main now has a new Chapter 3 that your branch doesn't have.${NC}"
echo ""
echo "--- main branch log ---"
git --no-pager log --oneline
pause

# ---- Show BEFORE state ------------------------------------------------------
header "📊 BEFORE rebase — notice where feature diverges from main"
git --no-pager log --oneline --graph --all
pause

# ---- Rebase -----------------------------------------------------------------
header "✏️  REBASING: Rewriting your notebook on top of the latest notes"
echo "Running: git checkout feature/my-notes && git rebase main"
echo ""
echo "This is like rewriting your notebook pages neatly so it LOOKS like"
echo "you started taking notes AFTER Chapter 3 was already published."
echo "Your ideas stay the same, but the pages are brand new copies."
pause

git checkout feature/my-notes
git rebase main

echo ""
echo -e "${GREEN}✅ Rebase complete!${NC}"
echo ""

# ---- Show AFTER state -------------------------------------------------------
header "📊 AFTER rebase — notice the clean, linear history"
git --no-pager log --oneline --graph --all

echo ""
header "🔍 Compare commit hashes — BEFORE vs AFTER"
echo ""
echo "BEFORE rebase (old hashes — these no longer exist):"
echo -e "${RED}$BEFORE_HASHES${NC}"
echo ""
echo "AFTER rebase (new hashes — rewritten copies):"
AFTER_HASHES=$(git --no-pager log --oneline feature/my-notes ^main)
echo -e "${GREEN}$AFTER_HASHES${NC}"
echo ""
echo -e "${YELLOW}⚠️  Notice: The commit messages are the same, but the HASHES changed!"
echo -e "This is why rebase is called 'rewriting history'.${NC}"
pause

# ---- Show result ------------------------------------------------------------
header "📄 Final file contents"
echo "--- notes.txt ---"
cat notes.txt
echo ""
echo "--- my-notes.txt ---"
cat my-notes.txt

echo ""
header "🎯 Key Takeaways"
echo "• Rebase replayed your commits ON TOP of the latest main."
echo "• The history is now LINEAR — no merge commit needed."
echo "• But the commit hashes CHANGED (D → D', E → E')."
echo ""
echo -e "${RED}⚠️  THE GOLDEN RULE:${NC}"
echo -e "${RED}   If you already pushed/shared your branch, do NOT rebase!${NC}"
echo -e "${RED}   Others have the OLD hashes. Rewriting will cause conflicts.${NC}"
echo -e "${RED}   Use MERGE instead — it's always safe.${NC}"
echo ""
echo -e "${CYAN}Demo repo is at: $DEMO_DIR${NC}"
echo "Feel free to explore it with 'git log --oneline --graph --all'"
echo ""
