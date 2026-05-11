---
name: emtrip-document-gen
description: "EmTripの契約文書・事業文書をdocx形式で生成するスキル。EmTrip固有のカラー・レイアウト・命名規則に従って文書を生成する。「契約書を生成して」「docxを作って」「文書を更新して」などで発動。必ずdocx skillと組み合わせて使うこと。"
---

# EmTrip 文書生成スキル

## 0. このスキルの使い方

このスキルはEmTrip固有の文書生成仕様を定義する。
実際の生成は `/mnt/skills/public/docx/SKILL.md` と組み合わせて行う。

**必ず最初に `/mnt/skills/public/docx/SKILL.md` を読んでから生成を開始すること。**

---

## 1. EmTrip ブランド仕様

### カラーパレット
```javascript
const COLORS = {
  primary: "4653A2",    // EmTrip blue（見出し・ヘッダー）
  accent: "ED6D46",     // EmTrip orange（強調・ボックス）
  headerBg: "4653A2",  // テーブルヘッダー背景
  headerText: "FFFFFF", // テーブルヘッダー文字
  rowAlt: "EEF0FA",    // テーブル交互行
  white: "FFFFFF",
  border: "CCCCCC",
  darkGray: "333333",   // 本文
};
```

### フォント
- 全文書：Arial統一
- 本文サイズ：22（11pt相当）
- 見出し1：28pt bold primary色
- 見出し2：24pt bold darkGray

### ページ設定
- 用紙：A4（width: 11906, height: 16838 DXA）
- マージン：top/right/bottom/left = 1440 DXA（1inch）

---

## 2. 文書別仕様

### 文書A：実証実験基本契約書
```
ファイル名：文書A_実証実験基本契約書_EmTrip×高橋商店_v{N}.docx
ヘッダー：「株式会社EmTrip | 実証実験基本契約書（文書A）　機密：高橋商店 実証実験専用」
フッター：「© 2026 株式会社EmTrip　info@emtrip.io　{ページ}/{総ページ}」
```

### 文書B：運用ルールブック
```
ファイル名：文書B_運用ルールブック_EmTrip×高橋商店_v{N}.docx
ヘッダー：「株式会社EmTrip | 運用ルールブック（文書B）　機密：高橋商店 実証実験専用」
```

### 文書C：エンドユーザー利用条件
```
ファイル名：文書C_エンドユーザー利用条件_ココロクロス_v{N}.docx
ヘッダー：「株式会社EmTrip | エンドユーザー向け利用条件（文書C）　機密：高橋商店 実証実験専用」
```

---

## 3. コンポーネント仕様

### テーブル（必須ルール）
```javascript
// 2列テーブル（標準）
// columnWidths: [2800, 6560] 合計9360 DXA
// ShadingType.CLEAR（SOLID禁止）
// cell margins: top:100, bottom:100, left:140, right:140
// border color: "CCCCCC"
// 交互行: rowAlt色
```

### 重要ポイントボックス（文書C冒頭）
```javascript
// accent色（ED6D46）の枠線8pt四辺
// 背景：FEF3ED（薄オレンジ）
// ShadingType.CLEAR
// 見出し行：bold・accent色
```

### numbering config
```javascript
// "bullets"：第1レベル bullet（•）
// "numbers"：第1レベル decimal
// "bullets2"：第2レベル bullet（◦）
// ※ unicode bullets禁止。必ずLevelFormat.BULLETを使う
```

---

## 4. サービス名・固有名詞の正確な表記

### 絶対ルール（2026-05-08更新：旧キリル文字運用は廃止）
| 正しい表記 | 誤った表記 | 備考 |
|-----------|-----------|------|
| ココロクロス | ococロクロス / cocorロクロス | 全てカタカナ。Claude Code/Claude.aiでの文字化けは編集時に必ず修正する |
| Cocoro Cross | cocoro cross / COCORO X | 英字表記（公式は単語頭大文字） |
| オーナーAI | AIコンシェルジュ | 旧称。使わない |
| 旅行者とお店をつなぐサービス | — | ココロクロスの定義 |
| お店のオーナーとAIでいつでも話せる仕組み | — | オーナーAIの定義 |
| 中川社長とAIで話せる | 中川社長のAIと話せる | 主語に注意 |

### 住所・連絡先
```
EmTrip：〒904-0004 沖縄県沖縄市中央一丁目7-8
高橋商店：〒834-0031 福岡県八女市本町2-22-1
EmTrip連絡先：info@emtrip.io
高橋商店連絡先：s.esaki@shigemasu.co.jp
```

---

## 5. 生成フロー

### Step 1：バージョン確認
現在の最新バージョンを確認してからvN+1で生成する。

### Step 2：変更箇所の特定
全文を読んでから変更箇所をstr_replaceで差分適用する。
全文書を再生成する場合はmakeDocA/makeDocB/makeDocC関数を更新する。

### Step 3：生成・検証
```bash
node gen_docs.js
# 生成後にpython3でテーブル含む全文を読んで整合確認
python3 -c "
from docx import Document
doc = Document('文書X_...vN.docx')
for p in doc.paragraphs:
    if p.text.strip(): print(p.text[:150])
for t in doc.tables:
    for row in t.rows:
        cells = [c.text.strip() for c in row.cells if c.text.strip()]
        if cells: print('TABLE:', ' | '.join(cells[:3]))
"
```

### Step 4：整合チェック
emtrip-contract-review スキルのチェックリストを使って3文書の整合を確認する。

### Step 5：出力
```
/mnt/user-data/outputs/ に配置してpresent_filesで提示
```

---

## 6. よくある生成ミスと対策

| ミス | 対策 |
|------|------|
| ココロクロスがキリル文字に文字化け（ococロクロス等） | grep -n 'ococロクロス\|ококロクロス\|cocorロクロス' で検出して ココロクロス に置換 |
| テーブルが黒背景になる | ShadingType.SOLIDではなくShadingType.CLEARを使う |
| bullet点が文字化け | unicodeではなくLevelFormat.BULLETを使う |
| 管轄裁判所がA・Cで不一致 | 全文書「東京地方裁判所（合意管轄）」で統一 |
| 削除期限の不整合 | 個別ユーザー30日（B・C）と全体終了後90日（A）は別物 |
| ページ番号が出ない | Footer内でPageNumber.CURRENT / TOTAL_PAGESを使う |
