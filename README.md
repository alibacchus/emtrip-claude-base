# emtrip-claude-base

EmTrip 特化 Claude Code 環境（skills + memory + CLAUDE.md）を、与那国Mac → 石垣Mac へ移植するためのリポジトリ。

**作成日**: 2026-05-11
**作成者**: 与那国賢一（CEO）
**初期対象ユーザー**: 石垣秀樹（営業）／将来は宮城信 + 7月ジョイン2名にも同じ手順で配布

---

## 何ができるか

このリポジトリを石垣のMacで clone → `install.sh` を実行すると、**EmTrip の思想・スキル・記憶を持った Claude Code** が石垣のMacでも動きます。

具体的には:

- **`~/.claude/CLAUDE.md`**: EmTrip グローバルルール（経営優先順位・行動規範・CEOアドバイザー設定）
- **`~/.claude/skills/emtrip-*/`**: EmTrip 専用スキル 14個（事業context・CEO壁打ち・契約書レビュー・デザイン・コンテンツ生産パイプライン 等）
- **`~/.claude/skills/digital-agency-dashboard/`**: ダッシュボード設計スキル
- **`~/.claude/projects/-Users-${USER}/memory/`**: EmTrip 会社記憶（MVV・3店舗情報・チームメンバー・戦略アップデート 等）

→ 石垣の Claude Code で「ココロクロス3店舗の所在地は？」と聞くと **正確に答える**。「emtrip-ceoで壁打ちして」と言うと **CEOアドバイザーモード** が起動する。

---

## 何が**入っていない**か（今回スコープ外）

| 種別 | 理由 | 対処方法 |
|---|---|---|
| **APIキー類** | 個人 Anthropic アカウントに紐付き、共有不能 | 石垣個別で claude.ai サブスク契約後 `claude` CLI で login |
| **MCP接続情報** | 各MCP (mfc_ca/Gmail/Drive/Slack/Notion等) は個人 OAuth | `docs/FUTURE-MCP-SETUP.md` 参照・必要になった時点で追加 |
| **書籍コーパス** | 数十〜数百MB の PDF 群 | `docs/FUTURE-BOOKS-SETUP.md` 参照・Google Drive 共有 or USB |
| **emtrip-miniapp 等の実コード** | GitHub上の別リポジトリ | 必要になったら別途 git clone |
| **個人セッション履歴** | 機密性が高い + 個人ごとに別 | コピー対象外 |

---

## 石垣向け 3 ステップ セットアップ

詳細手順は **`docs/SETUP-CHECKLIST.md`** を参照。要約だけ:

```bash
# 1. クローン
git clone https://github.com/alibacchus/emtrip-claude-base.git ~/emtrip-claude-base

# 2. 自動セットアップ
cd ~/emtrip-claude-base
bash install.sh

# 3. 動作確認
bash verify.sh
```

→ 完了。`claude` を起動して「EmTripのMVVを教えて」と聞けば動作する。

---

## リポジトリ構造

```
emtrip-claude-base/
├── README.md                  ← この文書
├── install.sh                 ← 自動セットアップ
├── uninstall.sh               ← 戻す用
├── verify.sh                  ← 動作確認
├── .gitignore                 ← 個人情報除外
├── claude/
│   ├── CLAUDE.md              ← グローバル指示
│   ├── skills/                ← EmTrip スキル 14個 + dashboard
│   └── memory/                ← 会社記憶 9ファイル
└── docs/
    ├── SETUP-CHECKLIST.md     ← 石垣向け詳細手順
    ├── WHATS-INSIDE.md        ← 入ってる物の中身（何のスキル？何の記憶？）
    ├── FUTURE-MCP-SETUP.md    ← 将来 MCP/APIキー追加するときのガイド
    ├── FUTURE-BOOKS-SETUP.md  ← 将来 書籍コーパス追加するときのガイド
    └── TROUBLESHOOTING.md     ← トラブル時の対応
```

---

## 仕組み（technical）

- **CLAUDE.md と skills/** は **symlink** で設置する。リポジトリを `git pull` すれば自動的に最新化される。
- **memory/** は **コピー** で設置する。石垣が自分で新しい記憶を追加・編集できるように。
- **既存 `~/.claude/` 配下のファイル**は **タイムスタンプ付き backup** に避難される（`~/.claude/backups/YYYYMMDD_HHMMSS/`）。`uninstall.sh` で復元可能。

---

## アップデート方法

与那国がスキルや CLAUDE.md を更新したとき:

```bash
cd ~/emtrip-claude-base
git pull
# symlink 方式なので、これだけで石垣の ~/.claude/skills/* も自動的に最新化される
```

memory に新しい記憶が追加されたとき（与那国側で）: 

```bash
cd ~/emtrip-claude-base
git pull
# memory はコピー方式なので、新規ファイルだけ手動コピー:
cp -n claude/memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/
# -n は existing file を上書きしないオプション（石垣の追加メモを守る）
```

---

## 与那国向け: GitHub Push 手順

このリポジトリは **ローカルで commit 済み**。`git push` だけ与那国が手動で実行する必要あり（sandbox 制約のため Claude Code から push 不可）。

### 1. GitHub で Private Repo を作成

ブラウザで https://github.com/new を開き:
- Repository name: `emtrip-claude-base`
- Visibility: **Private**
- Initialize this repository: **何もチェックしない**（README/gitignore/license 全部スキップ）
- 「Create repository」をクリック

### 2. ローカルから push

ターミナルで:

```bash
cd ~/emtrip-claude-base
git push -u origin main
```

初回 push 時に GitHub の認証（HTTPS なら personal access token、SSH なら鍵）を聞かれる。

### 3. 石垣を Collaborator に追加

GitHub の repo ページ → Settings → Collaborators → Add people → 石垣の GitHub ユーザー名を入力 → invite

---

## 与那国向け: ファイル更新ワークフロー

スキルや CLAUDE.md を編集した後の手順:

```bash
# 与那国Mac で:
cd ~/emtrip-claude-base
# 1. 自分の ~/.claude/ で編集したファイルをリポジトリへ反映:
cp ~/.claude/CLAUDE.md claude/CLAUDE.md
cp -r ~/.claude/skills/emtrip-* claude/skills/   # 全emtrip-skill更新時
# 2. 必要に応じて memory も:
cp ~/.claude/projects/-Users-yaima-nohito8/memory/*.md claude/memory/
# 3. commit & push:
git add -A
git commit -m "update: <変更内容>"
git push
```

将来的には自動同期する pre-commit hook も検討可能（必要になったら docs に追加）。

---

## ライセンス / 機密

このリポジトリは **EmTrip Inc. 社内資料**。**Private GitHub Repo** として運用し、外部公開しない。

含まれる情報:
- EmTrip 経営戦略（v3.6 / v4.0 由来）
- 取引先情報（髙橋商店・池原酒造・シーサー注意・連絡先）
- 経営者・チームメンバーの本名・役割
- PoC 結果数値・キャッシュ状況に関する記述（memory 内）

→ 必ず Private のまま運用。Public 化禁止。

---

## 連絡先

問題があれば与那国（CEO）まで。
