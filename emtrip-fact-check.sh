#!/bin/bash
# emtrip-fact-check.sh
# 外部発信文書（メール・トークスクリプト・SNS投稿・営業文・提案書）の
# ハルシネーション・テンプレ補完創作・出典なし断定を機械的に検出する。
#
# 使い方:
#   bash emtrip-fact-check.sh <ファイルパス>
#   bash emtrip-fact-check.sh draft.md
#   cat draft.txt | bash emtrip-fact-check.sh -
#
# 設計原則: Claude の判断を介さない・純粋 grep ベース。
# 「Claude が言った」より「実ファイルが何を言っているか」で決める精神を体現。
#
# 作成: 2026-05-12 / EmTrip Inc.

set -u

# === 色定義 (bash ANSI-C 引用で実際のESC文字に展開) ===
RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
GRAY=$'\033[0;90m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# === 引数チェック ===
if [ $# -eq 0 ]; then
  echo "Usage: bash emtrip-fact-check.sh <file>"
  echo "       cat <file> | bash emtrip-fact-check.sh -"
  echo ""
  echo "外部発信文書のハルシネーション機械検出ツール"
  echo "詳細: emtrip-claude-base/emtrip-fact-check.sh"
  exit 2
fi

FILE="$1"

# stdin 読み込み対応
if [ "$FILE" = "-" ]; then
  TMPFILE=$(mktemp)
  cat > "$TMPFILE"
  FILE="$TMPFILE"
  TMPMODE=1
else
  TMPMODE=0
  if [ ! -f "$FILE" ]; then
    echo -e "${RED}❌ ファイルが見つかりません: $FILE${NC}"
    exit 2
  fi
fi

# === カウンタ ===
FATAL=0     # A: 既知ハルシネーション
WARN=0      # B/C: テンプレ補完 / 出典なし断定

# === ヘッダ ===
echo -e "${BOLD}${BLUE}=========================================================${NC}"
echo -e "${BOLD}${BLUE}  EmTrip Fact Check (機械的ハルシネーション検出)${NC}"
echo -e "${BOLD}${BLUE}=========================================================${NC}"
echo -e "  対象: ${CYAN}$FILE${NC}"
echo -e "  文字数: $(wc -m < "$FILE" | tr -d ' ') / 行数: $(wc -l < "$FILE" | tr -d ' ')"
echo ""

# === A. 既知ハルシネーションパターン（即修正必須・FATAL） ===
echo -e "${BOLD}=== A. 既知ハルシネーションパターン（即修正必須）===${NC}"

check_fatal() {
  local pattern="$1"
  local correct="$2"
  local note="$3"
  local count=$(grep -c "$pattern" "$FILE" 2>/dev/null)
  count=${count:-0}
  if [ "$count" -gt 0 ]; then
    echo -e "${RED}❌ \"$pattern\" 検出 ($count 箇所) → ${BOLD}$correct${NC}${RED} へ修正${NC}"
    if [ -n "$note" ]; then
      echo -e "   ${GRAY}$note${NC}"
    fi
    grep -n "$pattern" "$FILE" | head -3 | sed "s|^|   ${GRAY}L|; s|\$|${NC}|"
    FATAL=$((FATAL+1))
  fi
}

# 法人名
check_fatal "EmTrip株式会社" "株式会社EmTrip" "前株・後株が逆"

# サービス名 (誤バリエーション)
check_fatal "こころクロス" "ココロクロス" "全カタカナ"
check_fatal "ここいく" "ココロクロス" "完全な誤り"
check_fatal "ココロ X" "ココロクロス" ""
check_fatal "ococロクロス" "ココロクロス" "キリル文字混入"
check_fatal "cocorロクロス" "ココロクロス" "キリル文字混入"
check_fatal "ококロクロス" "ココロクロス" "キリル文字混入"

# 中川社長
check_fatal "中川拓義" "中川拓也" "髙橋商店19代蔵元"
check_fatal "中川孝之" "中川拓也" ""

# 池原・池城混同
check_fatal "池原宏宇" "池原優(池原酒造) または 池城安司(シーサー注意)" "文脈で判断"
check_fatal "池城安治" "池城安司" "シーサー注意オーナー"
check_fatal "池城康司" "池城安司" ""

# 所在地
check_fatal "瀬底島" "瀬長島" "瀬底島は沖縄北部・別の島"

# 英表記
check_fatal "EmTrip Co., Ltd." "EmTrip Inc." "正式英表記"

# チームメンバー (読み方)
check_fatal "石垣ヒロキ" "石垣秀樹(ヒデキ)" "読みはヒロキでなくヒデキ"
check_fatal "宮城ヒデキ" "宮城信(まこと)" "誤・宮城信のひらがな読みはまこと"
check_fatal "砂川誠" "宮城信(まこと)" "過去のハルシネーション例"

# 店舗名キリル化や別表記
check_fatal "島の駅ぷざま" "シーサー注意" "完全に存在しない店名・ハルシネーション例"

if [ $FATAL -eq 0 ]; then
  echo -e "${GREEN}✅ A. 既知ハルシネーション: 検出なし${NC}"
fi
echo ""

# === B. テンプレ補完創作パターン（要事実確認 or 削除）===
echo -e "${BOLD}=== B. テンプレ補完創作パターン（実データの出典確認 or 削除）===${NC}"

check_warn() {
  local pattern="$1"
  local category="$2"
  local guidance="$3"
  local count=$(grep -c "$pattern" "$FILE" 2>/dev/null)
  count=${count:-0}
  if [ "$count" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  \"$pattern\" 出現 ($count 箇所) — $category${NC}"
    echo -e "   ${GRAY}$guidance${NC}"
    grep -n "$pattern" "$FILE" | head -2 | sed "s|^|   ${GRAY}L|; s|\$|${NC}|"
    WARN=$((WARN+1))
  fi
}

# B-1: お客様の声 / 好評 系
check_warn "お客様の声" "顧客証言" "実証実験で取得した声があるか？無ければセクション削除"
check_warn "ユーザーの声" "顧客証言" "同上"
check_warn "好評" "実績主張" "PoC純粋アクティブ0.25%段階で『好評』と書ける根拠なし → 削除推奨"
check_warn "多くの方" "実績主張" "数値根拠あるか？無ければ削除"
check_warn "多くのお客様" "実績主張" "同上"
check_warn "ご好評をいただ" "実績主張" "出典必要"
check_warn "ご評価をいただ" "実績主張" "出典必要"

# B-2: 業界平均 / 比較
check_warn "業界平均" "業界比較" "社外比較データなし・削除推奨"
check_warn "他社比" "業界比較" "比較データ出典なし → 削除"
check_warn "業界トップ" "権威付け" "根拠なし"

# B-3: 成功事例
check_warn "成功事例" "実績主張" "連携店舗3店舗のみ・『成功』と呼べる実証データなし"
check_warn "実績が" "実績主張" "数値出典必要"
check_warn "導入実績" "実績主張" "実証実験段階・本格導入は0件"

# B-4: 権威付け
check_warn "認証取得" "権威付け" "該当する認証なし"
check_warn "受賞" "権威付け" "受賞歴なし"
check_warn "メディア掲載" "権威付け" "該当なし・出典必要"
check_warn "○○大学" "権威付け" "共同研究等の事実なし"
check_warn "共同研究" "権威付け" "該当なし"

# B-5: 数値の出典なし
check_warn "向上いたしました" "効果主張" "before/after 数値の出典必要"
check_warn "削減いたしました" "効果主張" "同上"

if [ $WARN -eq 0 ]; then
  echo -e "${GREEN}✅ B. テンプレ補完: 検出なし${NC}"
fi
echo ""

# === C. 出典なし断定 ===
echo -e "${BOLD}=== C. 出典なし断定（要確認）===${NC}"

C_WARN=0
check_c() {
  local pattern="$1"
  local note="$2"
  local count=$(grep -c "$pattern" "$FILE" 2>/dev/null)
  count=${count:-0}
  if [ "$count" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  \"$pattern\" 出現 ($count 箇所) — $note${NC}"
    grep -n "$pattern" "$FILE" | head -2 | sed "s|^|   ${GRAY}L|; s|\$|${NC}|"
    C_WARN=$((C_WARN+1))
    WARN=$((WARN+1))
  fi
}

check_c "100%" "断定表現・出典がない限り削除"
check_c "絶対に" "断定表現"
check_c "必ず" "断定表現・例外が一つでもあれば削除"
check_c "間違いなく" "断定表現"
check_c "確実に" "断定表現"
check_c "唯一" "排他主張・他社調査結果あるか？"
check_c "最高の" "比較最上級・出典必要"
check_c "最大の" "比較最上級・出典必要"

if [ $C_WARN -eq 0 ]; then
  echo -e "${GREEN}✅ C. 出典なし断定: 検出なし${NC}"
fi
echo ""

# === D. 推奨セルフチェック (情報提供) ===
echo -e "${BOLD}=== D. 推奨セルフチェック ===${NC}"
echo -e "${CYAN}本文の各段落について、以下4分類のどれかをタグ付けしたか？${NC}"
echo "   (a) FACT     — memory/skill にある事実 → ✅"
echo "   (b) DOC      — 添付資料・Read済ファイルにある事実 → ✅"
echo "   (c) INFER    — 自分の推論 → 「(推論)」と明記"
echo "   (d) TEMPLATE — 文書の型由来の創作 → ❌ 削除"
echo ""
echo -e "${CYAN}P33 起草後3ステップ完了したか？${NC}"
echo "   ステップ1: 固有名詞 grep（このスクリプトの A セクション）"
echo "   ステップ2: 出所自問プロセス（FACT/DOC/INFER/TEMPLATE）"
echo "   ステップ3: 自己分析の信頼性チェック"
echo ""

# === 判定 ===
echo -e "${BOLD}${BLUE}=========================================================${NC}"
if [ $FATAL -gt 0 ]; then
  echo -e "${BOLD}${RED}  判定: ❌ FATAL ($FATAL 件) — このまま外部発信不可${NC}"
  echo -e "${RED}  A セクションの全項目を修正してから再実行してください${NC}"
elif [ $WARN -gt 0 ]; then
  echo -e "${BOLD}${YELLOW}  判定: ⚠️  WARN ($WARN 件) — 出典確認 or 削除${NC}"
  echo -e "${YELLOW}  B/C の各項目について事実根拠の有無を確認し、無ければ削除${NC}"
  echo -e "${YELLOW}  参照: emtrip-document-gen §4「文書テンプレート補完の絶対禁止セクション」${NC}"
else
  echo -e "${BOLD}${GREEN}  判定: ✅ クリーン — 外部発信可${NC}"
  echo -e "${GREEN}  最終確認: 与那国本人または別Claudeセッションで再読込みも推奨${NC}"
fi
echo -e "${BOLD}${BLUE}=========================================================${NC}"

# === cleanup ===
if [ "$TMPMODE" = "1" ]; then
  rm -f "$TMPFILE"
fi

# 終了コード
if [ $FATAL -gt 0 ]; then
  exit 1
elif [ $WARN -gt 0 ]; then
  exit 1
else
  exit 0
fi
