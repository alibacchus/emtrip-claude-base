#!/bin/bash
# emtrip-post-tool-fact-check.sh
#
# Claude Code の PostToolUse フック (Edit/Write 後に発火)。
# 外部発信向け文書 (Desktop/外部発信/契約/営業 配下の .md/.txt) に対して
# emtrip-fact-check.sh を自動実行し、FATAL 検出時は decision=block で
# Claude に修正させる。
#
# 設計原則:
# - 速さ重視: 適用範囲を厳密に絞り、対象外は即 exit 0
# - 偽陽性ゼロ重視: WARN ではブロックしない (FATAL のみブロック)
# - 透明性: ブロック理由は Claude にそのまま渡す
#
# Stdin: Claude Code が JSON で tool_input 等を渡す
# Stdout: 通常は空 (exit 0)。ブロックする時のみ JSON で decision/reason 出力
# Exit code: 0 = pass-through, 2 = block (補助的・stdout JSON が正)

set -u

INPUT="$(cat 2>/dev/null || true)"

# tool_input.file_path を取り出す (jq があれば使う / 無ければ素朴 grep)
FILE_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
  FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
fi
if [ -z "$FILE_PATH" ] && [ -n "$INPUT" ]; then
  FILE_PATH="$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)"
fi

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# 拡張子フィルタ: .md / .txt のみ
case "$FILE_PATH" in
  *.md|*.txt|*.MD|*.TXT) ;;
  *) exit 0 ;;
esac

# 除外パス: 内部ファイルにはハルシネーション検知の意味なし
case "$FILE_PATH" in
  */.claude/*)               exit 0 ;;
  */emtrip-claude-base/*)    exit 0 ;;
  */.git/*)                  exit 0 ;;
  */node_modules/*)          exit 0 ;;
  */memory/*)                exit 0 ;;
  */\.cache/*)               exit 0 ;;
  *MEMORY.md)                exit 0 ;;
esac

# 適用パス: 外部発信向け文書が置かれる典型ディレクトリのみ
TARGET=false
case "$FILE_PATH" in
  */Desktop/*)         TARGET=true ;;
  */外部発信/*)         TARGET=true ;;
  */契約/*)             TARGET=true ;;
  */営業/*)             TARGET=true ;;
  */drafts/*)          TARGET=true ;;
  */outgoing/*)        TARGET=true ;;
esac
[ "$TARGET" = false ] && exit 0

FACT_CHECK="$HOME/emtrip-claude-base/emtrip-fact-check.sh"
[ ! -x "$FACT_CHECK" ] && exit 0

# fact-check 実行 (色コード除去して JSON safe にする)
RESULT="$(bash "$FACT_CHECK" "$FILE_PATH" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || true)"

# FATAL 判定
if echo "$RESULT" | grep -q "判定: ❌ FATAL"; then
  REASON="$(printf '%s' "外部発信文書 ($FILE_PATH) でハルシネーション (FATAL) を検出しました。修正してから再保存してください。
---
$RESULT
---
emtrip-document-gen §4 / CLAUDE.md 公式固有名詞リスト を参照。" | head -c 4000)"

  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg reason "$REASON" '{decision: "block", reason: $reason}'
  else
    REASON_ESCAPED="$(printf '%s' "$REASON" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo "\"fact-check FATAL detected\"")"
    printf '{"decision":"block","reason":%s}\n' "$REASON_ESCAPED"
  fi
  exit 2
fi

exit 0
