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

# === 5. settings.json（無ければ最小テンプレ作成 / 既存ならhookだけ追記）===
echo -e "${YELLOW}[5/8] settings.json（最小テンプレ / hook 追記）...${RESET}"

if [ ! -f ~/.claude/settings.json ]; then
  cat > ~/.claude/settings.json <<EOF
{
  "advisorModel": "claude-opus-4-7",
  "effortLevel": "high",
  "showThinkingSummaries": true,
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$REPO_DIR/bin/emtrip-post-tool-fact-check.sh"
          }
        ]
      }
    ]
  }
}
EOF
  echo -e "${GREEN}    ✅ settings.json created (with fact-check hook)${RESET}"
else
  echo "    既存の settings.json を保護"
  if grep -q "emtrip-post-tool-fact-check.sh" ~/.claude/settings.json; then
    echo -e "${GREEN}    ✅ fact-check hook は既に登録済み${RESET}"
  else
    cp ~/.claude/settings.json "$BACKUP_DIR/settings.json.original"
    # python3 で安全に hook を merge (jq 依存を避ける)
    python3 - "$HOME/.claude/settings.json" "$REPO_DIR/bin/emtrip-post-tool-fact-check.sh" <<'PYEOF'
import json, sys, os
path = sys.argv[1]
hook_cmd = sys.argv[2]
with open(path) as f:
    data = json.load(f)
hooks = data.setdefault("hooks", {})
post = hooks.setdefault("PostToolUse", [])
new_entry = {
    "matcher": "Edit|Write|NotebookEdit",
    "hooks": [{"type": "command", "command": hook_cmd}]
}
# 既に同じ command があるか確認
already = False
for h in post:
    for inner in h.get("hooks", []):
        if inner.get("command") == hook_cmd:
            already = True
if not already:
    post.append(new_entry)
with open(path, "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PYEOF
    echo -e "${GREEN}    ✅ fact-check hook を追記${RESET}"
  fi
fi

# === 6. bin/ wrapper を PATH に登録 ===
echo -e "${YELLOW}[6/8] ets wrapper を PATH に登録...${RESET}"
chmod +x "$REPO_DIR/bin/ets" "$REPO_DIR/bin/emtrip-post-tool-fact-check.sh"

# 使用シェルを判定
SHELL_RC=""
case "${SHELL:-/bin/zsh}" in
  */zsh) SHELL_RC="$HOME/.zshrc" ;;
  */bash) SHELL_RC="$HOME/.bashrc" ;;
esac

if [ -n "$SHELL_RC" ]; then
  PATH_LINE="export PATH=\"$REPO_DIR/bin:\$PATH\""
  if [ -f "$SHELL_RC" ] && grep -qF "$REPO_DIR/bin" "$SHELL_RC"; then
    echo -e "${GREEN}    ✅ PATH 設定は $SHELL_RC に既に存在${RESET}"
  else
    echo "" >> "$SHELL_RC"
    echo "# === EmTrip Claude wrapper (ets) ===" >> "$SHELL_RC"
    echo "$PATH_LINE" >> "$SHELL_RC"
    echo -e "${GREEN}    ✅ PATH 設定を $SHELL_RC に追記${RESET}"
    echo -e "${YELLOW}    ⚠️  新しい設定を有効にするには: source $SHELL_RC または新しいターミナルを開く${RESET}"
  fi
else
  echo -e "${YELLOW}    ⚠️  シェル判定不可・手動で PATH に $REPO_DIR/bin を追加してください${RESET}"
fi

# === 7. fact-check 本体を chmod ===
echo -e "${YELLOW}[7/8] fact-check スクリプトを実行可能化...${RESET}"
chmod +x "$REPO_DIR/emtrip-fact-check.sh" "$REPO_DIR/verify-behavioral.sh" 2>/dev/null || true
echo -e "${GREEN}    ✅ chmod 完了${RESET}"

# === 8. 完了 ===
echo -e "${YELLOW}[8/8] 動作確認指示...${RESET}"
echo ""
echo -e "${GREEN}============================================${RESET}"
echo -e "${GREEN}  ✅ セットアップ完了${RESET}"
echo -e "${GREEN}============================================${RESET}"
echo ""
echo "次にやること:"
echo -e "  1. ${BLUE}exec \$SHELL${RESET} (or 新しいターミナルを開く) で PATH を有効化"
echo -e "  2. ${BLUE}bash $REPO_DIR/verify.sh${RESET} を実行して動作確認"
echo "     (内部で行動テストも実行・Claude Code を実起動して固有名詞チェック・1-2分)"
echo -e "  3. Claude Code を起動: ${BLUE}ets${RESET}  ← 推奨 (memory が確実に load される)"
echo -e "     ${YELLOW}※ 素の ${BLUE}claude${RESET}${YELLOW} だと CWD によって memory が読まれない可能性${RESET}"
echo "  4. 試しに聞いてみる:"
echo "     - \"EmTripのMVVを教えて\""
echo "     - \"ココロクロス3店舗のオーナーの本名を教えて\""
echo "     - \"emtrip-ceoで壁打ちして\""
echo ""
echo "外部発信文書を書いたら自動 fact-check が走ります:"
echo "  - Desktop / 外部発信 / 契約 / 営業 配下の .md/.txt が対象"
echo "  - FATAL 検出時は Claude にブロックメッセージが返り再修正を促します"
echo -e "  - 手動実行: ${BLUE}bash $REPO_DIR/emtrip-fact-check.sh <ファイル>${RESET}"
echo ""
echo "問題が出たら: docs/TROUBLESHOOTING.md を参照、または与那国へ連絡"
echo ""
echo "将来のアップデート（与那国がスキル更新したとき）:"
echo "  cd $REPO_DIR && git pull"
echo "  （symlink方式なので git pull だけで自動反映）"
echo ""
