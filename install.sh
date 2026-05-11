#!/bin/bash
# emtrip-claude-base install script
# 石垣のMacに EmTrip 特化 Claude Code 環境を構築する
# 与那国賢一 - 2026-05-11
set -e

# === 0. このスクリプトの位置を取得 ===
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_NAME=$(whoami)
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER_NAME}/memory"
BACKUP_DIR="$HOME/.claude/backups/$(date +%Y%m%d_%H%M%S)"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BLUE}============================================${RESET}"
echo -e "${BLUE}  EmTrip Claude Code 環境セットアップ${RESET}"
echo -e "${BLUE}============================================${RESET}"
echo "  Repo: $REPO_DIR"
echo "  User: $USER_NAME"
echo "  Memory will be at: $MEMORY_DIR"
echo "  Backup of existing files: $BACKUP_DIR"
echo ""

# === 1. 前提チェック ===
echo -e "${YELLOW}[1/6] 前提チェック...${RESET}"

if ! command -v claude >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Claude Code CLI (claude コマンド) が見つかりません${RESET}"
  echo "    後で必要になります。docs/SETUP-CHECKLIST.md を参照してください。"
  echo "    インストール: https://docs.claude.com/claude-code/quickstart"
  echo ""
fi

# 既存環境のバックアップディレクトリ
mkdir -p "$BACKUP_DIR"
mkdir -p ~/.claude

# === 2. CLAUDE.md（symlink化）===
echo -e "${YELLOW}[2/6] CLAUDE.md 配置...${RESET}"

if [ -e ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  echo "    既存の CLAUDE.md を backup へ移動"
  mv ~/.claude/CLAUDE.md "$BACKUP_DIR/CLAUDE.md.original"
elif [ -L ~/.claude/CLAUDE.md ]; then
  rm ~/.claude/CLAUDE.md
fi
ln -s "$REPO_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
echo -e "${GREEN}    ✅ CLAUDE.md installed (symlink)${RESET}"

# === 3. skills/（個別 symlink）===
echo -e "${YELLOW}[3/6] skills/ 配置...${RESET}"

mkdir -p ~/.claude/skills
for skill_dir in "$REPO_DIR/claude/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  target=~/.claude/skills/"$skill_name"

  # 既存があってかつsymlinkでないならbackup
  if [ -d "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$BACKUP_DIR/skill_${skill_name}"
    echo "    既存の $skill_name を backup へ移動"
  elif [ -L "$target" ]; then
    rm "$target"
  fi

  ln -s "$skill_dir" "$target"
  echo -e "${GREEN}    ✅ $skill_name${RESET}"
done

# === 4. memory/（コピー = 石垣が自分でメモリを更新できるように）===
echo -e "${YELLOW}[4/6] memory/ 配置...${RESET}"

mkdir -p "$MEMORY_DIR"

# 既存memoryをbackup
for f in "$MEMORY_DIR"/*.md; do
  if [ -f "$f" ]; then
    mv "$f" "$BACKUP_DIR/memory_$(basename $f)"
  fi
done

cp "$REPO_DIR/claude/memory/"*.md "$MEMORY_DIR/"
echo -e "${GREEN}    ✅ memory installed at: $MEMORY_DIR${RESET}"
echo "       （memory は symlink ではなく実コピー。理由: 石垣が自分のメモリを${YELLOW}自由に追加・編集できるように${RESET}）"

# === 5. settings.json（無ければ最小テンプレ作成）===
echo -e "${YELLOW}[5/6] settings.json（最小テンプレ）...${RESET}"

if [ ! -f ~/.claude/settings.json ]; then
  cat > ~/.claude/settings.json <<'EOF'
{
  "advisorModel": "claude-opus-4-7",
  "effortLevel": "high",
  "showThinkingSummaries": true
}
EOF
  echo -e "${GREEN}    ✅ settings.json created (minimal)${RESET}"
else
  echo "    既存の settings.json を尊重・触らず"
fi

# === 6. 完了 ===
echo -e "${YELLOW}[6/6] 動作確認指示...${RESET}"
echo ""
echo -e "${GREEN}============================================${RESET}"
echo -e "${GREEN}  ✅ セットアップ完了${RESET}"
echo -e "${GREEN}============================================${RESET}"
echo ""
echo "次にやること:"
echo "  1. ${BLUE}bash verify.sh${RESET} を実行して動作確認"
echo "  2. Claude Code を起動: ${BLUE}claude${RESET}"
echo "  3. 試しに聞いてみる:"
echo "     - \"EmTripのMVVを教えて\""
echo "     - \"ココロクロス3店舗の所在地は？\""
echo "     - \"emtrip-ceoで壁打ちして\""
echo ""
echo "問題が出たら: docs/TROUBLESHOOTING.md を参照、または与那国へ連絡"
echo ""
echo "将来のアップデート（与那国がスキル更新したとき）:"
echo "  cd $REPO_DIR && git pull"
echo "  （symlink方式なので git pull だけで自動反映）"
echo ""
