---
name: EmTrip コンテンツ運用パイプライン軽量版
description: SEO記事・SNS投稿・Custom GPTのコンテンツ運用を CLAUDE.md オーケストレーター + atoms.csv 共有データ層で軽量に回すスキル。「コンテンツパイプライン」「atoms」「投稿ネタ」「SNS運用」「SEO記事ネタ」のキーワードで発動。v3.6 §41 SNS開設タスクとPhase ε と並行で稼働。
---

# EmTrip コンテンツ運用パイプライン軽量版（KAWAI型 atoms.csv）

## 0. このスキルの位置づけ

CLAUDE.mdの「ツール整備・パイプライン構築（7月まで禁止）」例外として、5/9 MTG で合意した軽量版コンテンツパイプライン。

**目的**：v3.6 §41 のSEO記事3本（4言語）・Custom GPT 3本・SNS開設（日本語=LINE QR/多言語=Web QR）を solo founder で破綻させずに回す。

**まこと工数ゼロ**で構築可能。与那国本人が CSV 1ファイル運用するだけ。

---

## 1. 設計原則（KAWAI 一人マーケ 2026-04 由来・推論）

KAWAI氏（21スキル統合運用者）の手法を EmTrip 文脈に圧縮：

- **CLAUDE.md がオーケストレーター**：個別スキルは独立せず、共通の人格・優先順位・品質基準で動く（既に実装済）
- **共有データ層 atoms.csv** で素材を一元化：素材の重複・矛盾・抜け漏れを物理的に防ぐ
- **3つの軸を入力時に決める**：素材種類／対象チャネル／公開予定日

軽量版は **atoms.csv 1ファイルのみ** 運用。pipeline.csv / outputs.csv は traction が出てから追加。

---

## 2. atoms.csv の運用ルール

### 配置場所（推奨）
- 与那国の content 作業ディレクトリ（例：`~/Desktop/emtrip-content/atoms.csv`）
- ~/.claude/skills/ 配下には**置かない**（個別の作業データのため）
- Claude Code セッション開始時に `cat atoms.csv` または `Read` で読み込ませる

### スキーマ（最小カラム7つ）

| カラム | 型 | 説明 | 例 |
|---|---|---|---|
| atom_id | string | YYYY-MM-DD-XX の連番 | 2026-05-08-01 |
| title | string | 30字以内のネタ要約 | 「ぷざま」事件から学ぶハルシネーション対策 |
| source | string | 出所（observation / news / interview / book / experience） | observation |
| channel_intent | string | 想定チャネル（複数可、 / 区切り） | note / X / Custom GPT |
| language | string | ja / zh-tw / zh-cn / en / ko / es / fr | ja |
| status | string | draft / scheduled / published / killed | draft |
| memo | string | 100字以内・なぜ書きたいか／関連v3.6章番号 | v3.6 §13 calibrated thesis 補強 |

### 運用フロー（毎週月曜 15分）
1. 先週生まれた素材（観察・対話・ニュース受信）を atoms.csv に追記
2. status=draft の中から「今週公開する3-5件」に scheduled をつける
3. emtrip-cowork（note/X 文体）/ emtrip-design（サムネ）/ emtrip-prompts（テンプレ）と組み合わせて執筆
4. 公開後 status を published に変更・公開URL末尾を memo 末尾に追記

---

## 3. EmTrip 文脈での「素材＝atom」の典型ソース

| ソース | 具体例 | 期待頻度 |
|---|---|---|
| observation | 髙橋商店PoC実数（純粋アクティブ0.25%）・ベロ族発見 | 月2-3 |
| news | YC RFS 更新・OpenMythos 事件・Anthropic新機能 | 月2-3 |
| interview | 中川社長・池原優・池城安司との対話メモ | 月1-2 |
| book | ~/Desktop/biz-context/ 等から得た原文 | 月1-2 |
| experience | 公庫面談・税理士打合せ・MTGの気づき | 月3-5 |

**月10-15件のatoms / 内 5-7件を公開** が現実的なペース（推論）。

---

## 4. v3.6 §41 タスクとの紐付け

### SEO記事3本（4言語）
- atoms.csv からSEO適性高いもの（observation / book 由来）を選び writer-article 起動
- emtrip-cowork §6.4 note記事の型に従う
- 4言語版は機械翻訳ベース＋ネイティブチェック（推論：宮城信不要・外注または DeepL）

### Custom GPT 3本
- atoms.csv から「3チャネル別アイデンティティ」を抽出
  - GPT 1：Tomoe（髙橋商店向け繁桝ガイド）→ ja + en
  - GPT 2：Yuu（池原酒造向け泡盛ガイド）→ ja + zh-tw
  - GPT 3：Yasushi（シーサー注意向けお土産ナビ）→ ja + zh-cn + en
- 各 GPT の system prompt に atoms.csv の interview ソースを混ぜ込む

### SNS開設
- 日本語投稿 → LINE QR を末尾に固定
- 多言語投稿 → Web QR を末尾に固定
- v3.6 §21-1 推奨チャネル × LINE/Web 配置 と整合

---

## 5. やらないこと（7月まで）

- pipeline.csv / outputs.csv 等の追加 CSV 作成（軽量版逸脱）
- ダッシュボード化（KAWAI のtoday-analytics相当）
- 自動投稿スクリプト（まこと工数発生）
- 4言語コンテンツの自動翻訳パイプライン（外注で運用、軽量版維持）
- 過剰なAI生成画像投入（emtrip-design §2 禁止パターン抵触）

---

## 6. 月次見直しトリガー

以下のいずれかで「軽量版を超える整備」の議論を再開する（CLAUDE.md やらないこと例外協議）：

- atoms.csv が **月20件超で記入が追いつかなくなった**
- published の中で **再生数/インプレッション差が10倍以上ばらつき始めた**（→ pipeline.csv で可視化価値）
- 翻訳・投稿スケジュール管理が手動で破綻し始めた

---

## 7. 参照スキル

- 文体・問いかけ → `emtrip-cowork`
- デザイン・サムネ → `emtrip-design`
- 定型プロンプト → `emtrip-prompts`
- 事業根拠・差別化 → `emtrip-biz-context`
- 法的チェック（景表法）→ `emtrip-legal-check`

---

## 厳守事項

- atoms.csv 自体は ~/.claude/skills/ 配下に置かない（個別作業データ）
- atom_id は時系列ID。published 後も削除しない（履歴として保持）
- 4言語化は機械翻訳のまま投稿しない（必ず人間チェック後）
- ハルシネーション禁止（CLAUDE.md グローバル）
- 「ココロクロス」「Cocoro Cross」等の固有名詞表記は emtrip-document-gen §4 の絶対ルールに従う
