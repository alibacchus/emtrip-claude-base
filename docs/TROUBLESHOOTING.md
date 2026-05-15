# TROUBLESHOOTING.md — トラブル時の対応

## install.sh が失敗する

### 症状: `Permission denied`

```bash
chmod +x install.sh uninstall.sh verify.sh
bash install.sh
```

### 症状: `set -e` で途中で止まる

エラーメッセージをそのまま与那国に送付。原因例:
- `~/.claude/` ディレクトリの権限不正
- backup ディレクトリの作成失敗

応急対応:
```bash
sudo chown -R $(whoami) ~/.claude
bash install.sh
```

---

## verify.sh で FAIL が出る

### FAIL: `~/.claude/CLAUDE.md が存在`

→ install.sh が完了していない。再実行:
```bash
bash install.sh
```

### FAIL: `claude コマンドが見つかる`

→ Claude Code CLI が未インストール。
```bash
which node || brew install node
npm install -g @anthropic-ai/claude-code
claude --version
```

### FAIL: symlink target が存在 (broken)

→ リポジトリの場所が install.sh 実行時と変わった可能性。
```bash
# 一度クリーンに戻して再実行
bash uninstall.sh
bash install.sh
```

---

## Claude Code 起動時の問題

### 起動時に「ログインしてください」と出る

→ 初回 OK。ブラウザで Claude.ai にログイン。

### "Rate limit exceeded" と出る

→ 無料プランの利用上限。Max プラン契約推奨。

### スキルが発動しない

→ Claude Code を再起動。それでも発動しないとき:

```bash
# シンボリックリンクが切れてないか確認
ls -la ~/.claude/skills/ | grep emtrip

# CLAUDE.md が読めるか確認
cat ~/.claude/CLAUDE.md | head -10
```

CLAUDE.md が空 or symlink 切れなら install.sh 再実行。

---

## Memory が読まれない

### 症状: 「EmTripのMVVを教えて」に答えない

```bash
# memoryディレクトリのパスを確認（自分のユーザー名で展開されているか）
ls ~/.claude/projects/-Users-$(whoami)/memory/
# → MVV含む9ファイルが見えるはず

# MEMORY.md の中身確認
cat ~/.claude/projects/-Users-$(whoami)/memory/MEMORY.md
```

memoryファイルが無いとき:
```bash
cd ~/emtrip-claude-base
cp claude/memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/
```

---

## git pull で conflict が出る

### 症状: 自分のスキル変更とリモート変更がぶつかった

```bash
# 自分の変更をいったん退避
git stash

# リモート最新を取得
git pull

# 退避した変更を戻す（必要なら）
git stash pop
```

それでも解決しないとき:
```bash
# 強制リセット（**自分の変更は失われる**）
git fetch
git reset --hard origin/main
```

→ ローカル編集はリポジトリではなく `~/.claude/` 配下で行うことを推奨（リポジトリは「与那国管理」の前提）。

---

## CLAUDE.md を自分用にカスタマイズしたい

CLAUDE.md は symlink なので、リポジトリのファイルを編集すると与那国の Mac にも影響する。

**個人カスタマイズの推奨方法**:

```bash
# symlink を解除して個別ファイル化
rm ~/.claude/CLAUDE.md
cp ~/emtrip-claude-base/claude/CLAUDE.md ~/.claude/CLAUDE.md
# 編集
vim ~/.claude/CLAUDE.md
```

ただし、与那国の更新は `git pull` だけでは反映されなくなる。**自分で都度マージ**することになる。

→ 個人カスタマイズは memory 側で実現する方が運用しやすい:
```bash
# 自分用 memory を追加（与那国の memory と共存）
echo "私の個人ルール: XX" > ~/.claude/projects/-Users-$(whoami)/memory/personal_rules.md
```

---

## 完全に最初に戻したい

```bash
cd ~/emtrip-claude-base
bash uninstall.sh
```

それでも戻らないとき（手動完全クリーンアップ）:

```bash
# シンボリックリンク削除
find ~/.claude/skills -type l -delete
rm -f ~/.claude/CLAUDE.md

# memory 削除
rm -rf ~/.claude/projects/-Users-$(whoami)/memory

# backup 一覧確認
ls ~/.claude/backups/

# 最新 backup から手動復元
LATEST=$(ls -1dt ~/.claude/backups/*/ | head -1)
# 必要なファイルを手動で戻す
cp "$LATEST/CLAUDE.md.original" ~/.claude/CLAUDE.md 2>/dev/null
# skill_xxxx を ~/.claude/skills/ に戻す（必要なものだけ）
```

---

## ets コマンドが見つからない

### 症状: `command not found: ets`

PATH 設定が反映されていない。新しいターミナルを開くか:

```bash
exec $SHELL
# または
source ~/.zshrc
```

それでも見つからない時:

```bash
# 直接フルパスで起動
~/emtrip-claude-base/bin/ets

# PATH 設定を確認
grep emtrip-claude-base/bin ~/.zshrc ~/.bashrc 2>/dev/null
```

`~/.zshrc` に行が無ければ install.sh を再実行。

---

## ets で起動した Claude Code が固有名詞を間違える

### 症状: ets ですら「中川孝之」「島の駅ぷざま」等を出す

memory が読み込めていない。verify を実行して原因切り分け:

```bash
bash ~/emtrip-claude-base/verify.sh
# [5/5] 行動テストが FAIL なら問題確定
```

切り分け手順:

```bash
# 1. memory ファイル本体が存在するか
ls ~/.claude/projects/-Users-$(whoami)/memory/

# 2. MEMORY.md が壊れていないか
head -20 ~/.claude/projects/-Users-$(whoami)/memory/MEMORY.md

# 3. CLAUDE.md の symlink が生きているか
ls -la ~/.claude/CLAUDE.md
readlink ~/.claude/CLAUDE.md && cat $(readlink ~/.claude/CLAUDE.md) | head -5

# 4. それでも駄目なら install.sh 再実行
bash ~/emtrip-claude-base/install.sh
```

---

## 外部発信文書を書こうとすると Claude にブロックされる

### 症状: Desktop/契約/営業 配下の .md を保存しようとすると "fact-check FATAL"

これは仕様。固有名詞ハルシネーション(中川孝之・島の駅ぷざま 等)を機械的に検出して
保存をブロックしている。**指摘箇所を修正してから再保存**してください。

手動 fact-check で詳細確認:

```bash
bash ~/emtrip-claude-base/emtrip-fact-check.sh <ファイルパス>
```

A セクションの ❌ を全て修正 → クリーン判定が出れば再保存可能。

### 一時的に hook を無効化したい (緊急時のみ)

```bash
# 退避
mv ~/.claude/settings.json ~/.claude/settings.json.bak

# hook 抜きの最小 settings.json
cat > ~/.claude/settings.json <<'EOF'
{
  "advisorModel": "claude-opus-4-7",
  "effortLevel": "high"
}
EOF

# 作業後に戻す
mv ~/.claude/settings.json.bak ~/.claude/settings.json
```

緊急時のみ。常時 OFF にすると元の木阿弥。

---

## behavioral verify が FAIL する (verify.sh の [5/5])

### 症状: ファイル配置は OK だが Claude 出力で固有名詞が違う

これが「bootstrap 合格表示なのに実 Claude がハルシネーションする」状態を機械的に検知した結果。

切り分け:

```bash
# Step 1: --quick で home dir だけテスト
bash ~/emtrip-claude-base/verify-behavioral.sh --quick

# home dir で FAIL → memory が物理的に読まれていない
# home dir で PASS / 他で FAIL → CWD スコープ問題 (ets を使う)
```

home dir で FAIL の典型原因:

- Anthropic 認証が切れている (`ets` で起動して再ログイン)
- Rate limit (`Max プラン` 契約状況を確認)
- memory ディレクトリ名のミス (`-Users-` プレフィクス必須)
- Claude Code のバージョンが古い (`npm install -g @anthropic-ai/claude-code` で更新)

---

## 質問・要望

与那国（CEO）まで連絡。
ログ・エラーメッセージは省略せずそのまま送付。
