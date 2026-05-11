# FUTURE-BOOKS-SETUP.md — 将来 書籍コーパスを追加するときのガイド

## なぜ書籍コーパスがこのリポジトリに入っていないか

与那国Mac の `~/Desktop/` 配下にある書籍コーパス（PDF / markdown）はサイズが大きい（数十MB〜数百MB）ため、GitHub リポジトリには入れていない。

書籍コーパスは emtrip-biz-context・emtrip-cowork・emtrip-ceo・emtrip-design 等のスキルから参照される設計だが、スキル本体には**抽出済み概念が記述済み**なので、書籍原本が無くてもスキルの8割は機能する。

---

## 何が含まれるか（与那国Macの構成・参考）

| ディレクトリ | 冊数（概算） | 内容 |
|---|---|---|
| `~/Desktop/biz-context/` | 20冊 | ビジネス戦略・ピッチ・スタートアップ・両面市場・JTBD・観光客の哲学 等 |
| `~/Desktop/cowork/` | 12冊 | 対話・問いかけ・書く技術・アドラー勇気づけ・正義中毒・苫米地コーチング 等 |
| `~/Desktop/ceo/` | 18冊 | CEO 意思決定・失敗の本質・ファクトフルネス・武器になる哲学・シン・ニホン 等 |
| `~/Desktop/design/` | 8冊 | デザイン力の基本・ノンデザイナーズ・HIGH POWER MARKETING・売り方が9割 等 |
| `~/Desktop/EmTrip用一般書籍_md/` | 複数 | 各カテゴリ追加分（biz-context・cowork・ceo・design 配下） |

→ 詳細は与那国Mac の `emtrip-biz-context/EmTrip_学術資料_援用リスト.md` を参照（30件の評価リストあり）。

---

## 書籍コーパスが**必要になるケース**

スキル本体だけで十分なケースが多いが、以下の場合は書籍原本があると圧倒的に質が上がる:

| ケース | なぜ必要か |
|---|---|
| **Layer 3 ピッチ準備（米VC / AI Lab 向け）** | 学術引用の精度が問われる。Christensen JTBD / Eisenmann 両面市場 / 東浩紀 観光客の哲学 等の正確な引用 |
| **note の連載記事** | 引用元の原文を確認してニュアンスを保つ必要 |
| **新規スキル作成** | 既存スキルに無い概念を抽出するには原典必要 |
| **法務・契約レビュー** | 個人情報保護・景表法・消費者契約法 原文確認 |

---

## 追加方法（3つの選択肢）

### 方法1: Google Drive 共有フォルダ + symlink（推奨）

**長所**: 自動同期・与那国が書籍追加 → 石垣 Mac でも自動反映
**短所**: Google Drive の容量を消費（数百MB〜）

#### 手順:

1. **与那国側**:
   ```bash
   # Google Drive アプリ (Drive for desktop) をインストール
   # ~/Desktop/biz-context/ 等を Google Drive 内の「EmTrip-Books」フォルダにコピー
   # Google Drive のシェア設定で石垣にアクセス権付与（編集 or 閲覧）
   ```

2. **石垣側**:
   ```bash
   # Google Drive アプリをインストール（無ければ）
   # https://www.google.com/drive/download/

   # アプリ起動 → 同期完了を待つ

   # symlink を作成（石垣のメールアドレスを確認）
   GDRIVE_PATH=~/Library/CloudStorage/GoogleDrive-石垣のGmail/共有ドライブ/EmTrip-Books
   ln -s "$GDRIVE_PATH/biz-context" ~/Desktop/biz-context
   ln -s "$GDRIVE_PATH/cowork" ~/Desktop/cowork
   ln -s "$GDRIVE_PATH/ceo" ~/Desktop/ceo
   ln -s "$GDRIVE_PATH/design" ~/Desktop/design
   ln -s "$GDRIVE_PATH/EmTrip用一般書籍_md" ~/Desktop/EmTrip用一般書籍_md
   ```

### 方法2: USB-C 外付け SSD で一括コピー

**長所**: ネットワーク制限なし・即時
**短所**: 物理的に会う必要・将来更新が面倒

#### 手順:

1. 与那国側で外付け SSD に `~/Desktop/biz-context/` 等をコピー
2. 石垣に手渡し or 郵送
3. 石垣側で `cp -r` で自分の `~/Desktop/` 配下に展開

### 方法3: rsync / git LFS（上級者向け）

書籍コーパスを Private GitHub Repo に git LFS で push する方法。

**長所**: バージョン管理・差分のみ転送
**短所**: git LFS は GitHub の有料プランで容量制限あり（無料は 1GB / 月）・設定が手間

→ 通常は方法1か2で十分。

---

## 追加した後の動作確認

書籍コーパスを配置した後、Claude Code で以下を試す:

```
Read ~/Desktop/biz-context/airbnb-story.md
```

（具体的なファイル名は与那国の構成による。確認は与那国に問い合わせ）

ファイルが読めれば成功。emtrip-biz-context スキルが「以下の書籍を参照しています...」と引用するようになる。

---

## 注意事項

### ⚠️ 著作権

書籍 PDF / markdown は**個人利用前提**。社外公開・販売・SNS 投稿は著作権侵害になる。Private repo / Private Drive で運用する。

### ⚠️ 容量

書籍コーパス全体で数百MB〜1GB 規模。Mac のストレージ容量に余裕があることを確認。

### ⚠️ 与那国構成との差分

与那国Mac の構成は時期によって変わる。「与那国Mac の最新と完全同期したい」場合は、Google Drive 共有が最も楽（git pull のように自動同期される）。

---

## 優先順位（石垣のフェーズ別）

### Phase 1: 環境構築直後（5月）

**書籍コーパスは不要**。emtrip-* スキル内の抽出概念で十分。

### Phase 2: 営業・コンテンツ立ち上げ（6月）

- 必要に応じて Google Drive 共有を開始（与那国判断）

### Phase 3: ピッチ準備・本格コンテンツ生産（7月以降）

- Google Drive 共有を本格活用
- Layer 3 ピッチ向け学術引用などで原典必須
