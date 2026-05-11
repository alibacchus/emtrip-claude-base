---
name: 3プロジェクト構成と最終統合方針
description: emtrip-miniapp / emtrip-webchat / OPePe の役割分担、技術スタック差、最終統合に向けた共通化レイヤー
type: project
originSessionId: 9f9aa9d5-b912-4b34-aee8-5c52faab231f
---
EmTripのプロダクト・コードベースは現状3つに分かれている：

| プロジェクト | 位置づけ | スタック | 主要機能 |
|---|---|---|---|
| emtrip-miniapp | EmTripメイン事業（ココロクロス）のLINE LIFFミニアプリ本番フロント | LIFF + Express(server.ts) + Netlify Functions + Fly.io + Docker | chat.html / liff-starter.js / prompts / locales(7言語) / legal |
| emtrip-webchat | EmTripメイン事業のWebチャット版（多言語インバウンド+日本人LINE非利用層） | Next.js + Vercel | chat/page.tsx 900行実装済・7言語完全対応・multi-tenant `[store]` 動的ルート・Supabase Auth+Stripe連携済（v3.6 §6-2）。5/8時点で5ラリー制限/強制サブスク残存・Phase α-εで5月-6月に機能パリティ達成中 |
| OPePe (activity-ops) | EmTripサイドビジネス。マリン事業者向け当日事故防止特化システム | Next.js 16 (App Router) + Supabase + Tailwind + DeepL + pnpm | 集合案内・持ち物確認・安全同意・遅刻場所不明返却・チェックイン・天候判断 |

**Supabase（OPePe）：** project_id `ruetzdzvtasximltpgus` / org_id `07b434cf-3698-4659-8428-d93c81bd4655`

**Why:** アリーは3プロジェクトを最終統合する方針。共通化レイヤー（confirmation_logs / event_logs / action_logs / 認証 / テナント / 履歴 / 多言語）を揃え、ドメイン固有レイヤー（観光体験 / マリン体験 / 民泊）を載せる二層設計。

**How to apply:**
- 3プロジェクトのCLAUDE.md・.claude/settings.local.json は同じ思想で書く（スキル発火索引・MCP活用索引・コーポレートカラー・行動規範を統一）
- ドメイン用語の対応表：
  - emtrip-miniapp / emtrip-webchat：観光客 / 旅前旅中旅後 / 店舗
  - OPePe：ツアー参加者 / 事前ブリーフィング・当日運航・事後フォロー / 事業所
- データモデル共通基盤：confirmation_logs / event_logs / action_logs / page_delivery_logs（OPePeの先行設計を統合時の母体に）
- 実装ルール共通：テストファイル作成はheredoc禁止・python3 -c書き出し方式、SupabaseのserviceRole/anonKey混在禁止、コミット&プッシュ必須
- 統合タイミング：OPePeのPSF検証完了 + ココロクロス3店舗トラクション計測完了後（推定2026年7月以降）
- 統合に向けて壊さない設計判断：認証統一（Supabase Auth）／organization中心のRLS／ログテーブル名の互換／i18n key体系の互換
