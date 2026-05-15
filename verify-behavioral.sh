#!/bin/bash
# verify-behavioral.sh
#
# install.sh 完了後に「Claude Code が実際に正しい固有名詞・事実を返すか」を
# 行動テストで検証する。verify.sh のファイル配置確認(static)とは別レイヤ。
#
# 設計原則:
# - claude -p (non-interactive) で実出力を取得
# - 必須語の存在 + 禁止語の不在 + fact-check FATAL なし の3条件で PASS
# - 複数 CWD から実行し memory CWD スコープ問題も検出
# - claude 未インストールなら SKIP (FAIL ではない)
#
# 使い方:
#   bash verify-behavioral.sh
#   bash verify-behavioral.sh --quick  # home dir 1 ケースのみ (高速)
#
# 終了コード: 0=PASS, 1=FAIL, 2=SKIP

set -u

QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
BOLD=$'\033[1m'
NC=$'\033[0m'

PASS=0
FAIL=0

echo -e "${BOLD}${BLUE}=========================================================${NC}"
echo -e "${BOLD}${BLUE}  Behavioral verify (Claude Code runtime 出力テスト)${NC}"
echo -e "${BOLD}${BLUE}=========================================================${NC}"
echo ""

# claude バイナリ
CLAUDE_BIN=""
if command -v claude >/dev/null 2>&1; then
  CLAUDE_BIN="$(command -v claude)"
elif [ -x "$HOME/.local/bin/claude" ]; then
  CLAUDE_BIN="$HOME/.local/bin/claude"
else
  echo -e "${YELLOW}⚠️  claude CLI 未インストール — behavioral verify を SKIP${NC}"
  echo "    npm install -g @anthropic-ai/claude-code"
  exit 2
fi

FACT_CHECK="$HOME/emtrip-claude-base/emtrip-fact-check.sh"
[ ! -x "$FACT_CHECK" ] && { echo -e "${RED}❌ emtrip-fact-check.sh が見つからない${NC}"; exit 1; }

# 1 ケース実行
# 引数: ラベル CWD プロンプト 必須語(grep -E) 禁止語(grep -E)
run_test() {
  local label="$1"
  local cwd="$2"
  local prompt="$3"
  local required="$4"
  local forbidden="$5"

  echo -e "${CYAN}[$label]${NC} CWD=$cwd"
  echo -e "${GRAY}  Q: $prompt${NC}"

  if [ ! -d "$cwd" ]; then
    echo -e "${YELLOW}  ⚠️  CWD が存在しない・SKIP${NC}"
    return
  fi

  local output
  output="$(cd "$cwd" && "$CLAUDE_BIN" -p "$prompt" 2>/dev/null || true)"

  if [ -z "$output" ]; then
    echo -e "${RED}  ❌ Claude から出力なし (認証不足 or rate limit の可能性)${NC}"
    FAIL=$((FAIL+1)); echo ""; return
  fi

  echo -e "${GRAY}  A (先頭300字): $(echo "$output" | head -c 300 | tr '\n' ' ')${NC}"

  # 必須語チェック
  if ! echo "$output" | grep -qE "$required"; then
    echo -e "${RED}  ❌ 必須語 '$required' が含まれない${NC}"
    echo -e "${GRAY}     → memory が load されていない可能性大${NC}"
    FAIL=$((FAIL+1)); echo ""; return
  fi

  # 禁止語チェック
  local hit
  hit="$(echo "$output" | grep -oE "$forbidden" | head -1 || true)"
  if [ -n "$hit" ]; then
    echo -e "${RED}  ❌ 禁止語検出: '$hit'${NC}"
    FAIL=$((FAIL+1)); echo ""; return
  fi

  # fact-check FATAL チェック
  local fc_result
  fc_result="$(echo "$output" | bash "$FACT_CHECK" - 2>&1 | sed 's/\x1b\[[0-9;]*m//g')"
  if echo "$fc_result" | grep -q "判定: ❌ FATAL"; then
    echo -e "${RED}  ❌ fact-check FATAL 検出${NC}"
    echo "$fc_result" | grep "❌" | head -3 | sed "s|^|    ${GRAY}|; s|$|${NC}|"
    FAIL=$((FAIL+1)); echo ""; return
  fi

  echo -e "${GREEN}  ✅ PASS${NC}"
  PASS=$((PASS+1)); echo ""
}

# === テストケース定義 ===

# Case 1: home dir (memory が確実に load される CWD)
run_test "1/3 memory load (home)" "$HOME" \
  "ココロクロス3店舗のオーナー名をフルネームでカンマ区切り1行で答えて。説明や前置きは不要。" \
  "中川拓也" \
  "中川拓義|中川孝之|なかがわたくみ|池原宏宇|池原裕|池城安治|池城康司|島の駅ぷざま"

if [ "$QUICK" = "1" ]; then
  echo -e "${YELLOW}--quick 指定: 残り SKIP${NC}"
else
  # Case 2: Desktop CWD (memory load されない可能性が高い・CLAUDE.md だけで耐えられるか)
  mkdir -p "$HOME/Desktop"
  run_test "2/3 CLAUDE.md fallback (Desktop)" "$HOME/Desktop" \
    "シーサー注意の所在地と経営者名を 1 行で答えて。" \
    "瀬長島|豊見城" \
    "瀬底島|那覇市|池城安治|池城康司|島の駅ぷざま|cocorロクロス|ококロクロス"

  # Case 3: /tmp CWD (最も memory が読まれない環境・bare CLAUDE.md only)
  run_test "3/3 bare CLAUDE.md (/tmp)" "/tmp" \
    "EmTrip の CEO の本名と「ココロクロス」の英語表記を 1 行で答えて。" \
    "与那国賢一" \
    "与那国憲一|与那国宏|cocorロクロス|ококロクロス|COCORO CROSS|cocoro cross"
fi

# === 判定 ===
echo -e "${BOLD}${BLUE}=========================================================${NC}"
echo "  結果: ${GREEN}PASS: $PASS${NC} / ${RED}FAIL: $FAIL${NC}"
echo -e "${BOLD}${BLUE}=========================================================${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}失敗時のチェックリスト:${NC}"
  echo "  1. ets コマンドで起動しているか? (ets = home CWD で起動する wrapper)"
  echo "     インストール: bash ~/emtrip-claude-base/install.sh"
  echo "  2. memory ファイルが該当 CWD の projects 配下にあるか?"
  echo "     ls ~/.claude/projects/-Users-\$(whoami)/memory/"
  echo "  3. CLAUDE.md の symlink が壊れていないか?"
  echo "     ls -la ~/.claude/CLAUDE.md"
  echo "  4. Claude Code を再起動して再実行"
  exit 1
fi

exit 0
