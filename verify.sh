#!/bin/bash
# emtrip-claude-base verify script
# install.sh 実行後の動作確認用
set -e

USER_NAME=$(whoami)
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER_NAME}/memory"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

PASS=0
FAIL=0

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition"; then
    echo -e "${GREEN}✅ $label${RESET}"
    PASS=$((PASS+1))
  else
    echo -e "${RED}❌ $label${RESET}"
    FAIL=$((FAIL+1))
  fi
}

echo -e "${BLUE}============================================${RESET}"
echo -e "${BLUE}  EmTrip Claude Code 環境 動作確認${RESET}"
echo -e "${BLUE}============================================${RESET}"
echo ""

# === 1. ファイル配置確認 ===
echo -e "${YELLOW}[1/4] ファイル配置...${RESET}"

check "~/.claude/CLAUDE.md が存在" "[ -L ~/.claude/CLAUDE.md ] || [ -f ~/.claude/CLAUDE.md ]"
check "~/.claude/skills/emtrip-biz-context が存在" "[ -e ~/.claude/skills/emtrip-biz-context ]"
check "~/.claude/skills/emtrip-ceo が存在" "[ -e ~/.claude/skills/emtrip-ceo ]"
check "~/.claude/skills/emtrip-cowork が存在" "[ -e ~/.claude/skills/emtrip-cowork ]"
check "~/.claude/skills/emtrip-design が存在" "[ -e ~/.claude/skills/emtrip-design ]"
check "~/.claude/skills/emtrip-content-pipeline が存在" "[ -e ~/.claude/skills/emtrip-content-pipeline ]"
check "memory ディレクトリ ($MEMORY_DIR) が存在" "[ -d $MEMORY_DIR ]"
check "memory/MEMORY.md が存在" "[ -f $MEMORY_DIR/MEMORY.md ]"
check "memory/project_emtrip_mvv.md が存在" "[ -f $MEMORY_DIR/project_emtrip_mvv.md ]"
check "settings.json が存在" "[ -f ~/.claude/settings.json ]"

# === 2. symlink 健全性 ===
echo ""
echo -e "${YELLOW}[2/4] symlink 健全性...${RESET}"

if [ -L ~/.claude/CLAUDE.md ]; then
  target=$(readlink ~/.claude/CLAUDE.md)
  check "CLAUDE.md symlink target が存在 ($target)" "[ -f '$target' ]"
fi

skill_count=0
for skill in ~/.claude/skills/emtrip-*; do
  if [ -L "$skill" ]; then
    skill_count=$((skill_count+1))
    target=$(readlink "$skill")
    if [ ! -d "$target" ]; then
      echo -e "${RED}❌ $skill -> $target (broken)${RESET}"
      FAIL=$((FAIL+1))
    fi
  fi
done
echo -e "${GREEN}✅ emtrip-* symlinks: $skill_count 個（healthy）${RESET}"
PASS=$((PASS+1))

# === 3. 内容 sanity check ===
echo ""
echo -e "${YELLOW}[3/4] 内容 sanity check...${RESET}"

check "CLAUDE.md に '経営優先順位' が含まれる" "grep -q '経営優先順位' ~/.claude/CLAUDE.md"
check "CLAUDE.md に 'ココロクロス' が含まれる" "grep -q 'ココロクロス' ~/.claude/CLAUDE.md"
check "emtrip-biz-context に MVV 公式定義" "grep -q 'みんなの思い出をみんなの価値に変える' ~/.claude/skills/emtrip-biz-context/SKILL.md"
check "memory に MVV が記録されている" "grep -q 'みんなの思い出をみんなの価値に変える' $MEMORY_DIR/project_emtrip_mvv.md"
check "memory に 3店舗の所在地" "grep -q '池原酒造' $MEMORY_DIR/project_kokorocross_stores.md"

# === 4. Claude Code CLI ===
echo ""
echo -e "${YELLOW}[4/4] Claude Code CLI...${RESET}"

if command -v claude >/dev/null 2>&1; then
  echo -e "${GREEN}✅ claude コマンドが見つかる${RESET}"
  PASS=$((PASS+1))
else
  echo -e "${YELLOW}⚠️  claude コマンドが未インストール（後で OK）${RESET}"
fi

# === 結果 ===
echo ""
echo -e "${BLUE}============================================${RESET}"
echo "  結果: ${GREEN}PASS: $PASS${RESET} / ${RED}FAIL: $FAIL${RESET}"
echo -e "${BLUE}============================================${RESET}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}失敗あり。docs/TROUBLESHOOTING.md を参照してください。${RESET}"
  exit 1
fi

echo ""
echo -e "${GREEN}全て OK。Claude Code を起動してください: ${BLUE}claude${RESET}"
echo ""
echo "試しのプロンプト例:"
echo "  - \"EmTripのMVVを教えて\""
echo "  - \"ココロクロス3店舗の所在地は？\""
echo "  - \"emtrip-ceoでアドバイザーモード\""
echo "  - \"emtrip-cowork でメールの文面チェック\""
