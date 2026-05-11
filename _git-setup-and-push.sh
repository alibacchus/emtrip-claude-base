#!/bin/bash
# 与那国賢一 専用: git init → GitHub push を1コマンドで完了させるスクリプト
# Claude Code の sandbox 制約により .git/config への書き込みが拒否されたため、
# 与那国がターミナルで本スクリプトを1回実行する必要がある。
#
# 使い方:
#   cd ~/emtrip-claude-base
#   bash _git-setup-and-push.sh
#
# 前提:
#   1. GitHub で Private repo "emtrip-claude-base" を**手動で**作成済み
#      → https://github.com/new でこの名前 + Private + 何もinitializeしない
#   2. git config --global user.name / user.email が設定済み
#   3. https://github.com/alibacchus に push できる認証手段（PAT or SSH）がある
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

YELLOW="\033[33m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${YELLOW}========================================${RESET}"
echo -e "${YELLOW}  emtrip-claude-base Git Setup & Push${RESET}"
echo -e "${YELLOW}========================================${RESET}"
echo ""

# === 1. Prerequisites check ===
echo "[1/5] Prerequisites..."
GH_USER=$(git config --global user.name)
GH_EMAIL=$(git config --global user.email)
echo "  git user: $GH_USER <$GH_EMAIL>"

if [ -z "$GH_USER" ] || [ -z "$GH_EMAIL" ]; then
  echo -e "${RED}❌ git config --global user.name / user.email が未設定。先に設定してください:${RESET}"
  echo "  git config --global user.name \"alibacchus\""
  echo "  git config --global user.email \"fdgcb517@gmail.com\""
  exit 1
fi

# === 2. git init ===
echo ""
echo "[2/5] git init..."
if [ -d .git ]; then
  echo "  既に .git が存在。スキップ"
else
  git init -b main
  echo "  ✅ git init done"
fi

# === 3. git add + commit ===
echo ""
echo "[3/5] git add + commit..."
git add .

# 既にcommit済みかチェック
if git log -1 >/dev/null 2>&1; then
  echo "  既にcommit済み。差分のみadd済"
else
  git commit -m "$(cat <<'EOF'
initial commit: EmTrip-specialized Claude Code base

- CLAUDE.md: グローバル指示（経営優先順位・行動規範・CEOアドバイザー）
- skills/: EmTrip 専用スキル 14個 + digital-agency-dashboard
- memory/: 会社記憶 9ファイル（MVV・3店舗・チーム・戦略アップデート 等）
- install.sh / uninstall.sh / verify.sh: 自動セットアップ一式
- docs/: セットアップ・MCP拡張・書籍コーパス追加・トラブル対応ガイド

Target: 石垣秀樹のMacに同じClaude Code環境を構築するための配布用ベース。
MCP/APIキー周りは個人紐付きのため意図的に除外（docs/FUTURE-MCP-SETUP.md 参照）。

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  echo "  ✅ initial commit done"
fi

# === 4. remote add ===
echo ""
echo "[4/5] remote add..."
REMOTE_URL="https://github.com/alibacchus/emtrip-claude-base.git"
if git remote | grep -q "^origin$"; then
  CURRENT_URL=$(git remote get-url origin)
  if [ "$CURRENT_URL" != "$REMOTE_URL" ]; then
    git remote set-url origin "$REMOTE_URL"
    echo "  ✅ remote 'origin' updated → $REMOTE_URL"
  else
    echo "  既に正しい remote が設定済"
  fi
else
  git remote add origin "$REMOTE_URL"
  echo "  ✅ remote 'origin' added → $REMOTE_URL"
fi

# === 5. push ===
echo ""
echo "[5/5] push..."
echo -e "${YELLOW}  GitHub の Private Repo \"emtrip-claude-base\" を作成済みですか？${RESET}"
echo "  まだなら、ブラウザで作成してから push してください:"
echo "    1. https://github.com/new"
echo "    2. Repository name: emtrip-claude-base"
echo "    3. Private を選択"
echo "    4. README / .gitignore / license は全てチェックを外す"
echo "    5. \"Create repository\" をクリック"
echo ""
read -p "GitHub Repo 作成済みなら Enter / 中止する場合は Ctrl+C: "

git push -u origin main

echo ""
echo -e "${GREEN}========================================${RESET}"
echo -e "${GREEN}  ✅ Push 成功！${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo "次のステップ:"
echo "  1. ブラウザで https://github.com/alibacchus/emtrip-claude-base にアクセス確認"
echo "  2. Settings → Collaborators → 石垣を Add（GitHub username が必要）"
echo "  3. 石垣に docs/SETUP-CHECKLIST.md を送る or リポジトリの README を見せる"
echo ""
