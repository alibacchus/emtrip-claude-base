# WHATS-INSIDE.md — このリポジトリに入ってる物の中身

## 1. claude/CLAUDE.md（グローバル指示）

EmTrip 全体の経営優先順位・行動規範・モデル運用ルール・CEOアドバイザー設定。

**主な節**:
- 経営優先順位（2026年4月〜6月）：ココロクロス→決算→マツリクロス→OPePe
- やらないこと（7月まで禁止）：新機能の大幅追加・まこと工数が必要な実装
- 例外（2026-05-08 追加）：Track 5（UGC型 Demand Aggregation）／コンテンツ運用パイプライン軽量版
- コンテキスト管理ルール（Anthropic公式 Thariq原則 2026-05反映）
- CEOアドバイザー設定（与那国の専属戦略参謀として動作）

→ Claude Code を起動すると、これがグローバル指示として最初にロードされる。

---

## 2. claude/skills/（14個 + 1個）

各スキルは Claude Code に**専門能力**を与えるもの。「emtrip-ceo で壁打ちして」のように呼び出すか、関連キーワードで自動発動。

### 2-1. emtrip-biz-context（事業コンテキスト）

EmTrip の事業定義・MVV・ビジネスモデル・ピッチ用の書籍的根拠（20冊抜粋）。投資家ピッチ・営業資料・戦略判断時に発動。**重要**: v3.6 戦略フレーム（5 Tracks / 2 Moats / Calibrated Thesis）が§3.5にある。

### 2-2. emtrip-ceo（CEOアドバイザー）

与那国の専属戦略参謀。毎朝の優先順位確認・意思決定壁打ち・週次ズレ指摘・交渉/ピッチ準備・感情的場面での冷静視点提供・資金配分判断。FR-1〜FR-14 のフレームワーク + 資金調達Tier別エビデンス即答テンプレ付き。

### 2-3. emtrip-cowork（ブランドボイス）

EmTrip のブランドボイス・オーナーAI対話設計・旅前旅中旅後の問いテンプレ。メール・営業文・SNS投稿・note記事・LINEメッセージ・ピッチ・オーナーAI設計・ジャーナリング設計時に発動。

### 2-4. emtrip-design（デザインシステム）

EmTrip の UI・LP・スライド・ポップ・販促物の作成指針。コーポレートカラー（#4653A2 / #ED6D46）・非デザイナー失敗パターン・近接/整列/反復/コントラスト4原則・AISUS。**§7.5 に 2QR並列POP仕様（v4.0付録E）**。

### 2-5. emtrip-slide-template（スライド設計）

投資家資料・決算サマリー・事業者向け提案書のスライド構成。汎用8枚構成 + v3.6 Layer 2推奨10枚構成 + Layer 1/3別構成。

### 2-6. emtrip-prompts（定型プロンプト32選）

決算・集客・営業・運営・コンテンツ作成・競合分析・メール・意思決定など定型業務のテンプレ。P01〜P32（P26-P32 は v3.6 直結プロンプト：税理士問合せ・公庫予約・期限延長申請・LOI・Track5 warm intro・5層メトリクス・Layer別ピッチ）。

### 2-7. emtrip-contract-review（契約書レビュー）

PoC契約の3層設計（文書A/B/C）・ユーザー区分・二段階ライセンス構造・文書間整合チェック。**§6 に v3.6 追加（2契約モデル + LOI 7月末3件目標）**。

### 2-8. emtrip-document-gen（docx 文書生成）

EmTrip 固有のカラー・レイアウト・命名規則に従って docx 形式の文書生成。

### 2-9. emtrip-legal-check（法的チェック）

景表法・個人情報保護法・消費者契約法・特定商取引法の観点からリスク評価。hourei MCP と組み合わせて条文を参照する想定。

### 2-10. emtrip-owner-ai-faq（FAQ生成）

オーナーAI横展開用 FAQ 生成スキル。新店舗のアンケート・インタビュー文字起こしから faq_master 投入用 CSV を生成。

### 2-11. emtrip-owner-ai-chunk（chunk生成）

オーナーAI横展開用 chunk 生成スキル。chunk_master / chunk_embeddings の Supabase 投入用 CSV。

### 2-12. emtrip-owner-ai-persona（persona JSON生成）

オーナーAI横展開用 persona_message JSON 生成。Supabase Storage に配置する形式。

### 2-13. emtrip-content-pipeline（NEW・2026-05-08 追加）

KAWAI型 atoms.csv 軽量版コンテンツ運用パイプライン。SEO記事3本(4言語)+Custom GPT 3本+SNS開設の解像度を上げる目的。v4.0 §41 SNS開設タスクと並行で稼働。

### 2-14. digital-agency-dashboard（ダッシュボード設計）

デジタル庁のダッシュボードデザインガイドブック（2026年3月版）に基づいてダッシュボード設計。グラフ選択・カラーパレット・Do's/Don'ts。

---

## 3. claude/memory/（9ファイル）

会社のロールベース記憶。Claude Code が**全セッションを跨いで参照**する。

| ファイル | 内容 |
|---|---|
| MEMORY.md | 全memoryファイルのインデックス（一行サマリー） |
| team_members.md | アリー/まこと（宮城信）/ヒデキ（石垣秀樹）の本名・通称・役割 |
| project_emtrip_mvv.md | Mission「みんなの思い出をみんなの価値に変える」等の公式 MVV |
| project_kokorocross_stores.md | 髙橋商店（八女・酒蔵）/池原酒造（石垣・泡盛）/シーサー注意（豊見城市瀬長島・雑貨）の所在地・経営者・業種 |
| project_opepe_strategy_shift.md | 2026-04-30「勝ちに行く」転換 + 2026-05-08 石垣島ダイビング店PSF検証並走 |
| project_three_repos_integration.md | emtrip-miniapp（本番運用）/emtrip-webchat（Phase α-ε中・900行実装済）/OPePe の役割分担と統合方針 |
| project_emtrip_velo_zoku.md | 髙橋商店PoCで観察された「ベロ族」＝消費型参加層の定義 |
| feedback_offline_meeting_agenda.md | 対面MTGは前提修正・解釈合意に絞り、事実報告は事前スプシで非同期収集する原則 |
| feedback_data_uncertainty_block_response.md | 「データ不足だから話せない」というブロックへの切り返し方 |

---

## 4. 何が**入っていない**か

### 4-1. APIキー / 認証情報

- Anthropic API key
- Claude.ai セッショントークン
- 各 MCP の OAuth token

→ 各人が個別に取得・設定する。物理的にコピー不可能（claude.ai が個人アカウント紐付け）。

### 4-2. MCP 接続情報

| MCP | 用途 | 入ってない理由 | 追加方法 |
|---|---|---|---|
| mfc_ca | MF会計 (決算・仕訳) | 与那国アカウント紐付き | `docs/FUTURE-MCP-SETUP.md` |
| Gmail/Calendar/Drive | Google系 | 個人 Google アカウント紐付き | claude.ai 経由で接続 |
| Notion/Slack/Wix/Canva/Figma | 各種 SaaS | 個人アカウント紐付き | claude.ai 経由で接続 |
| EDINET | 金融開示 (公開API) | 公開なので追加可能 | `docs/FUTURE-MCP-SETUP.md` |
| hourei/labor-law/tax-law | 法令 (公開API) | 公開なので追加可能 | `docs/FUTURE-MCP-SETUP.md` |
| gyosei-fudosan/gyosei-kankouju | 行政情報 (公開) | 公開なので追加可能 | `docs/FUTURE-MCP-SETUP.md` |

### 4-3. 書籍コーパス

`~/Desktop/biz-context/`, `cowork/`, `ceo/`, `design/`, `EmTrip用一般書籍_md/` 配下の書籍 PDF / md。

→ サイズが大きい（数十MB〜数百MB）ためリポジトリには入れない。Skills の中に**抽出済み概念**は記述済みなので、書籍原本が無くてもSkillsの8割は機能する。深堀り引用が必要になった時のみ `docs/FUTURE-BOOKS-SETUP.md` を参照。

### 4-4. EmTrip プロダクトコード

- emtrip-miniapp（LINE版）
- emtrip-webchat（Web版）
- OPePe (activity-ops)

→ 別の GitHub リポジトリ。必要になったら個別に `git clone`。

### 4-5. 個人セッション履歴 / cache

- `~/.claude/sessions/`
- `~/.claude/cache/`
- `~/.claude/file-history/`
- `~/.claude/session-env/`
- `~/.claude/history.jsonl`

→ 機密性が高く、個人ごとに別。コピー対象外。

---

## 5. 何が**含まれているが特殊な扱い**か

### 5-1. settings.json（最小テンプレのみ）

`install.sh` が既存 settings.json が無い場合のみ、以下の最小テンプレを作成:

```json
{
  "advisorModel": "claude-opus-4-7",
  "effortLevel": "high",
  "showThinkingSummaries": true
}
```

既存 settings.json がある場合は触らない。Sandbox 設定や hooks 等の高度な設定が必要な場合は、個人で追加する。

### 5-2. MCP 設定 (mcp.json)

このリポジトリには**含めない**。MCP 接続情報は個人ごとに別なので、必要になったら `docs/FUTURE-MCP-SETUP.md` を参照して個別に追加。
