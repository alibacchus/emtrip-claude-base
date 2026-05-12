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

### 絶対ルール（2026-05-12更新：ハルシネーション抑制強化）
| 正しい表記 | 誤った表記（過去発生・全部禁止） | 備考 |
|-----------|-----------|------|
| **株式会社EmTrip**（前株） | EmTrip株式会社（後株） | 法人名・全文書で統一 |
| EmTrip Inc.（英表記） | EmTrip Co., Ltd. | 英語版 |
| ココロクロス（全カタカナ） | ococロクロス / cocorロクロス / **こころクロス** / **ここいく** / ココロ X | 2026-05-12 石垣Mac でハルシネーション再発・要警戒 |
| Cocoro Cross | cocoro cross / COCORO X | 英字表記（単語頭大文字） |
| オーナーAI | AIコンシェルジュ | 旧称。使わない |
| 旅行者とお店をつなぐサービス | — | ココロクロスの定義 |
| お店のオーナーとAIでいつでも話せる仕組み | — | オーナーAIの定義 |
| 中川社長とAIで話せる | 中川社長のAIと話せる | 主語に注意 |
| **中川拓也**（髙橋商店19代蔵元・たかはしショウテン） | **中川拓義** / 中川孝之 / なかがわたくみ | 2026-05-12 石垣Mac でハルシネーション再発・要警戒 |
| **池原優**（池原酒造3代目） | 池原宏宇 / 池原裕 | 「池」が共通の池城さんと混同注意 |
| **池城安司**（シーサー注意オーナー） | 池原宏宇 / 池城安治 / 池城康司 | 「池原」と「池城」を取り違えやすい |

### ハルシネーション再発時の対応
固有名詞ハルシネーションが発生したら、原因を以下から特定する：
- (A) skills/memory が context に乗っていない → プロンプト冒頭で memory/team_members.md 等を明示的に Read
- (B) 添付資料の渡し方が悪い → ファイルパスで Read コマンド使用
- (C) Claude が「自信なし」を明示せず創作した → CLAUDE.md「外部発信前の絶対ルール」3項違反・要再教育

### 文書テンプレート補完の絶対禁止セクション（2026-05-12 追加）

外部発信文書には「文書の型」として埋めたくなる定型セクションがあるが、**実データが無いなら絶対書かない**。創作で埋めるくらいなら**丸ごとセクション削除**。

#### 営業メール・トークスクリプトで創作禁止のセクション

| セクション | 何を書きがちか | 実データなしの正しい対応 |
|---|---|---|
| **お客様の声** | 「『中川さんと話しているようで八女の知らない話が聞けた』というお声をいただいております」 | **セクション丸ごと削除**。実証実験で取得した声があるなら memory または contract-review skill から確認 |
| **実績・好評** | 「ご来訪の方から好評をいただいております」「多くの観光客にご利用いただいております」 | **削除**。PoC実数は純粋アクティブ0.25%（v3.6）であり「好評」と書ける段階ではない |
| **業界平均比較** | 「業界平均の◯倍」「他社比◯%向上」 | **削除**。社外比較データなし |
| **成功事例** | 「他店舗でも◯◯の成果が出ています」 | **削除**。連携店舗は3店舗のみ・「成功事例」と呼べる実証データなし |
| **権威付け** | 「○○大学との共同研究」「○○認証取得」 | **削除**。該当する権威付けなし |
| **社会的証明** | 「メディア掲載」「受賞歴」 | **削除**。該当なし |

#### 営業メール・トークスクリプトで書いてよいセクション

| セクション | 出典 | 注意 |
|---|---|---|
| サービス概要 | emtrip-biz-context §1 / contract-review §1 | 公式文言で |
| 価格情報 | emtrip-biz-context §1 ビジネスモデル（v3.6 確定値） | 「月¥30,000-50,000・SaaS料」「Voice/IP 15%還元」等 |
| 連絡先・社名 | contract-review §1 「確定済み事実」 | 株式会社EmTrip（前株）／info@emtrip.io |
| 中川社長のエピソード | emtrip-owner-ai-chunk/references/chunk_examples.md の事実ベース 15件 | 「中川拓也氏は1974年三重県松阪市生まれ・建設業からの娘婿入り」等の事実は引用可 |
| 提案内容 | v4.0_distribution_plan.html の出面計画 | 「6月以降のPOP配備提案」等のスケジュール明示 |

#### 「お客様の声」「好評」を入れたくなったときの判断フロー

```
出力前に自問:
  ↓
「この『お客様の声』の実データは memory / skill / 資料のどこにあるか？」
  ↓
あれば: 出典明記 + 一字一句正確に引用
ない場合: ↓
  ↓
このセクションを書く必然性はあるか？
  ↓
ある: 「（実証期間中・お客様の声は未取得）」と明記 or 別のセクションに置換
ない: セクション丸ごと削除（テンプレに引きずられて書かない）
```

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
