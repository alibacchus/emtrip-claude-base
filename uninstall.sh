#!/bin/bash
# emtrip-claude-base uninstall script
# install.sh で配置した symlink を全て解除し、最新の backup を復元する
set -e

USER_NAME=$(whoami)
MEMORY_DIR="$HOME/.claude/projects/-Users-${USER_NAME}/memory"
LATEST_BACKUP=$(ls -1dt ~/.claude/backups/*/ 2>/dev/null | head -1)

YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${YELLOW}============================================${RESET}"
echo -e "${YELLOW}  EmTrip Claude Code 環境 アンインストール${RESET}"
echo -e "${YELLOW}============================================${RESET}"

if [ -z "$LATEST_BACKUP" ]; then
  echo -e "${RED}backup が見つかりません。手動でクリーンアップしてください。${RESET}"
  exit 1
fi
echo "Latest backup: $LATEST_BACKUP"
echo ""

read -p "本当に元に戻しますか? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "中止しました。"
  exit 0
fi

# 1. CLAUDE.md
if [ -L ~/.claude/CLAUDE.md ]; then
  rm ~/.claude/CLAUDE.md
  if [ -f "$LATEST_BACKUP/CLAUDE.md.original" ]; then
    mv "$LATEST_BACKUP/CLAUDE.md.original" ~/.claude/CLAUDE.md
    echo -e "${GREEN}✅ CLAUDE.md restored${RESET}"
  else
    echo -e "${YELLOW}⚠️ CLAUDE.md backup not found — symlink only removed${RESET}"
  fi
fi

# 2. skills (symlinkを全削除、backupから戻す)
for symlink in ~/.claude/skills/*; do
  if [ -L "$symlink" ]; then
    skill_name=$(basename "$symlink")
    rm "$symlink"
    backup_path="$LATEST_BACKUP/skill_${skill_name}"
    if [ -d "$backup_path" ]; then
      mv "$backup_path" ~/.claude/skills/"$skill_name"
      echo -e "${GREEN}✅ skill restored: $skill_name${RESET}"
    fi
  fi
done

# 3. memory (現在のmemoryをbackupへ、backupから戻す)
mkdir -p "$MEMORY_DIR.uninstall_temp"
mv "$MEMORY_DIR"/*.md "$MEMORY_DIR.uninstall_temp/" 2>/dev/null || true
for f in "$LATEST_BACKUP"/memory_*.md; do
  if [ -f "$f" ]; then
    original_name=$(basename "$f" | sed 's/^memory_//')
    mv "$f" "$MEMORY_DIR/$original_name"
  fi
done
echo -e "${GREEN}✅ memory restored${RESET}"

# 4. settings.json から fact-check hook を除去 (PostToolUse 配列のみ touch)
if [ -f ~/.claude/settings.json ] && grep -q "emtrip-post-tool-fact-check.sh" ~/.claude/settings.json; then
  python3 - ~/.claude/settings.json <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
hooks = data.get("hooks", {})
post = hooks.get("PostToolUse", [])
filtered = []
for h in post:
    inner = [i for i in h.get("hooks", []) if "emtrip-post-tool-fact-check.sh" not in i.get("command", "")]
    if inner:
        h["hooks"] = inner
        filtered.append(h)
if filtered or "PostToolUse" in hooks:
    if filtered:
        hooks["PostToolUse"] = filtered
    else:
        hooks.pop("PostToolUse", None)
with open(path, "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PYEOF
  echo -e "${GREEN}✅ settings.json から fact-check hook を除去${RESET}"
fi

# 5. PATH 設定行を削除 (~/.zshrc / ~/.bashrc)
for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$RC" ] && grep -qF "emtrip-claude-base/bin" "$RC"; then
    cp "$RC" "$RC.uninstall.bak"
    # 直前のコメント行と PATH 行を除去 (sed BSD/GNU 両対応のため tmp 経由)
    grep -v "emtrip-claude-base/bin" "$RC.uninstall.bak" | grep -v "# === EmTrip Claude wrapper" > "$RC"
    echo -e "${GREEN}✅ $RC から PATH 設定を除去 (元は $RC.uninstall.bak に退避)${RESET}"
  fi
done

echo ""
echo "アンインストール完了。"
echo "現環境の memory は $MEMORY_DIR.uninstall_temp/ に保存されています。"
echo "PATH 設定を有効化解除: exec \$SHELL または新しいターミナルを開く"
