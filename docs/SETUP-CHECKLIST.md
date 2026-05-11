# SETUP-CHECKLIST.md — 石垣向け詳細手順

EmTrip 特化 Claude Code 環境を、ご自身の Mac に構築する手順。

**所要時間: 30-60分**（Claude Code 自体のインストール含む。Claude Code が既に動いてれば 15分で完了）

---

## 前提

- Mac OS（M1/M2/M3 含む Intel も OK）
- ターミナル（標準アプリ・Spotlight で "Terminal" 検索）の基本操作
- GitHub アカウント（無料で OK・無ければ作る）
- Claude.ai アカウント（無料で OK・後で有料 Max プラン契約推奨）

---

## Step 0: 前提ツールを揃える

ターミナルで以下を順に実行。**全部コピペで OK**。

### 0-1. Homebrew がなければインストール

```bash
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

`which brew` で `/usr/local/bin/brew` か `/opt/homebrew/bin/brew` が出れば既に入ってる。

### 0-2. Git があるか確認（標準で入ってるはず）

```bash
which git
# /usr/bin/git などが出れば OK
```

無ければ `xcode-select --install` で Xcode Command Line Tools をインストール。

### 0-3. Claude Code CLI をインストール

```bash
# 公式手順（変わる可能性あり・最新は https://docs.claude.com/claude-code を確認）:
npm install -g @anthropic-ai/claude-code
```

`npm` がなければ:
```bash
brew install node
```

インストール後、確認:
```bash
claude --version
```

### 0-4. VSCode と Claude Code 拡張をインストール（任意・推奨）

```bash
brew install --cask visual-studio-code
```

VSCode を起動 → 拡張機能タブ → "Claude Code" で検索 → インストール。

---

## Step 1: リポジトリを clone

```bash
cd ~
git clone https://github.com/alibacchus/emtrip-claude-base.git
cd emtrip-claude-base
```

GitHub のアカウントで Collaborator として招待されている必要あり（与那国に確認）。

初回 clone で認証を聞かれる場合:
- **GitHub Desktop アプリ**を使うと楽（https://desktop.github.com からダウンロード）
- ターミナル派なら **Personal Access Token** を発行: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → 新規発行 → repo 権限にチェック → 発行されたトークンを clone 時のパスワード欄に貼り付け

---

## Step 2: 自動セットアップ実行

```bash
bash install.sh
```

実行結果として:

- 既存の `~/.claude/CLAUDE.md` などは `~/.claude/backups/YYYYMMDD_HHMMSS/` に退避される（戻したい時は `uninstall.sh` で復元可能）
- 新しい `~/.claude/CLAUDE.md` は `emtrip-claude-base/claude/CLAUDE.md` への **シンボリックリンク** になる（git pull すると自動更新される）
- 14 個の emtrip-* スキルと digital-agency-dashboard が `~/.claude/skills/` に配置される
- 9 ファイルの memory が `~/.claude/projects/-Users-${あなたのMacユーザー名}/memory/` に配置される
- 最小の `~/.claude/settings.json` が作成される（既存があれば触らない）

---

## Step 3: 動作確認

```bash
bash verify.sh
```

最後に `PASS: N / FAIL: 0` と表示されれば成功。

---

## Step 4: Claude Code を起動して試す

```bash
claude
```

初回起動時に Claude.ai でログインを求められる（ブラウザが開く）。Claude.ai のアカウントで認証。

起動後、以下を試す:

| 試すプロンプト | 期待する反応 |
|---|---|
| "EmTripのMVVを教えて" | Mission「みんなの思い出をみんなの価値に変える」等を正確に答える |
| "ココロクロス3店舗の所在地は？" | 髙橋商店（八女）/池原酒造（石垣）/シーサー注意（豊見城市瀬長島）と答える |
| "emtrip-ceo でアドバイザーモード" | CEOアドバイザーモードに切り替わり、フレームワーク付きで助言 |
| "emtrip-cowork でメールの文面チェック" | EmTrip ブランドボイスでチェック対応 |
| "emtrip-design で SNS バナー設計" | カラー #4653A2 / #ED6D46 を使った設計提案 |

正しい反応がなければ `docs/TROUBLESHOOTING.md` を確認。

---

## Step 5: Claude.ai 有料プランの契約（任意・推奨）

Claude Code は無料でも使えますが、長時間使うとレート制限に当たります。

- **Claude Max プラン**: 月 $100 程度・推奨
- 契約 URL: https://claude.ai/upgrade

法人カードで契約するか、個人カードで一旦契約 → 領収書を経費精算するかは与那国と相談。

---

## Step 6: アップデートの受け取り方

与那国がスキルを更新したとき、以下を実行するだけ:

```bash
cd ~/emtrip-claude-base
git pull
```

`CLAUDE.md` と `skills/` は **symlink** なので、これだけで `~/.claude/` 側も自動的に最新になります。

memory も最新化したい場合（与那国が新しい記憶ファイルを追加したとき）:

```bash
cd ~/emtrip-claude-base
cp -n claude/memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/
# -n は既存ファイルを上書きしないオプション（自分の追記が消えないように）
```

---

## トラブル時

`docs/TROUBLESHOOTING.md` を確認。それでも解決しなければ与那国へ連絡。
