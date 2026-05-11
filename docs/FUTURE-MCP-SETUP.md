# FUTURE-MCP-SETUP.md — 将来 MCP / API キーを追加するときのガイド

このリポジトリは「MCP / API キー周りを意図的に除外」しています。これらは個人アカウントに紐付くため。

このドキュメントは「**そういう機能もあるよ・必要になったら自分でこうやって追加してね**」ガイドです。

---

## MCP とは何か

**MCP** = Model Context Protocol。Claude Code が外部ツール（Google Drive・Gmail・Slack・MF会計 等）と話す仕組み。

例: MCP を入れると、Claude Code から:
- 「先週の領収書を Gmail から探して MF会計に入力して」
- 「Notion の議事録から要約してSlackに投稿して」
- 「Google Drive のスプシを見て分析して」

みたいなことが可能になる。

---

## 与那国Mac で動いている MCP 一覧（参考）

2026-05-11 時点で与那国 Claude Code に接続されている MCP:

### A. Anthropic 公式の Connector（claude.ai 経由・推奨）

| MCP | 用途 | 必要なもの |
|---|---|---|
| **Gmail** | メール仕分け・送信・検索 | Google アカウント |
| **Google Calendar** | 予定確認・作成 | Google アカウント |
| **Google Drive** | ファイル検索・読み込み | Google アカウント |
| **Notion** | DB 検索・ページ作成 | Notion アカウント |
| **Slack** | チャンネル読み込み・メッセージ送信 | Slack ワークスペース招待 |
| **Canva** | デザイン生成・編集 | Canva アカウント |
| **Figma** | デザイン読み込み・コード変換 | Figma アカウント |
| **Wix** | サイト管理（EmTrip 会社HP・B向けLP用） | Wix アカウント（与那国管理） |

### B. EmTrip 専用 MCP（業務 critical）

| MCP | 用途 | URL | 認証 |
|---|---|---|---|
| **mfc_ca** | MF会計 仕訳・試算表・取引先 | `https://beta.mcp.developers.biz.moneyforward.com/mcp/ca/v3` | MF会計アカウント・与那国側で石垣にアクセス権限付与必要 |

### C. 公開API MCP（誰でも追加可能）

| MCP | 用途 | 認証 |
|---|---|---|
| **EDINET** | 金融庁 EDINET（上場企業財務開示） | 不要 |
| **hourei** | e-Gov 法令検索 | 不要 |
| **labor-law** | 労働・社会保険法令と行政通達 | 不要 |
| **tax-law** | 税法（法令・通達・裁決事例） | 不要 |
| **gyosei-fudosan** | 行政・不動産API（国土交通省） | 不要 |
| **gyosei-kankouju** | 観光関連（観光庁） | 不要 |

---

## 石垣Mac で MCP を追加する方法

### 方法1: claude.ai の Connector（推奨・最も簡単）

1. ブラウザで https://claude.ai を開く（石垣のClaudeアカウントでログイン）
2. 左メニュー → **Settings** → **Connectors**
3. 「Gmail」「Google Drive」等の追加したいサービスを選択
4. 「Connect」 → OAuth 認証フローに従う（自分のGoogleアカウント等で許可）
5. Claude Code を再起動

→ 認証情報は Anthropic 側で管理されるので、`~/.claude/` 配下に秘密情報が直接置かれない。**最も安全**。

### 方法2: `claude mcp add` コマンド（CLI）

```bash
# 例: tax-law MCP を追加
claude mcp add --name tax-law --transport http --url https://<tax-law-mcp-url>

# 例: 公開 MCP の追加（認証不要のもの）
claude mcp add --name hourei --transport http --url https://<hourei-url>
```

接続できる MCP は Anthropic のディレクトリ参照: https://anthropic.com/mcp-marketplace

### 方法3: `~/.claude/mcp.json` を手動編集

```json
{
  "mcpServers": {
    "mfc_ca": {
      "url": "https://beta.mcp.developers.biz.moneyforward.com/mcp/ca/v3"
    },
    "tax-law": {
      "url": "https://<tax-law-url>"
    }
  }
}
```

→ ファイルを編集して Claude Code を再起動。

---

## 優先順位（石垣のフェーズ別）

### Phase 1: 6月前半（環境構築直後）

**何も追加しなくて OK**。emtrip-* スキルだけで「EmTrip 特化 Claude Code」として十分機能する。

### Phase 2: 6月中（営業活動が立ち上がったら）

| MCP | なぜ必要か |
|---|---|
| **Gmail** | 顧客とのやりとり管理・テンプレ送信 |
| **Google Calendar** | 訪問アポ・面談管理 |
| **Google Drive** | 提案資料・契約書ドラフトの共同編集 |

### Phase 3: 7月以降（決算サポートに入るなら）

| MCP | なぜ必要か |
|---|---|
| **mfc_ca** | 取引先登録・経費精算入力（**与那国に MF会計のメンバー追加を依頼**してから） |

### Phase 4: ピッチ / 投資家対応時

| MCP | なぜ必要か |
|---|---|
| **Notion** | ピッチ資料・投資家リスト管理 |
| **Slack** | チームコミュニケーション |
| **EDINET** | 投資家・競合企業の公開財務分析 |

---

## API キー設定（Claude Code 自体）

Claude Code は **Anthropic API キー** ではなく **Claude.ai セッショントークン**で動く（推奨）。

1. `claude` を起動
2. 初回ログインを求められたら、ブラウザで Claude.ai にログイン
3. 認証成功 → `~/.claude/` 配下にセッションが保存される（あなたの個人アカウント）

→ **API キーを直接設定する必要は通常ない**。

### 例外: API キー直接設定が必要なケース

- 企業ライセンスで強制的に API キー認証
- セルフホスト Anthropic API 利用
- Bedrock / Vertex AI 経由

→ 通常の石垣ユースケースでは関係なし。必要になったら別途調べる。

---

## 注意事項

### ⚠️ やってはいけないこと

1. **与那国の OAuth token を奪って使う**: 規約違反 + 事故のもと
2. **mcp.json に直接 APIキーを書いてリポジトリに push**: 漏洩リスク。`.gitignore` で除外済みだが念のため注意
3. **MCP を片っ端から追加する**: ノイズが増えて Claude Code の判断が遅くなる。必要なものだけ

### ✅ 守ること

1. **自分のアカウントで認証する**: 与那国・石垣でアカウント分離
2. **必要になってから追加**: Phase に合わせて段階的に
3. **困ったら与那国に聞く**: 経営に関わる MCP（MF会計等）は権限管理が絡む
