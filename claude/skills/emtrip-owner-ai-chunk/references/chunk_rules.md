# EmTrip chunk生成ルール v2.0

## chunkとは

**1つの意味だけを持ち、複数の質問に再利用できるオーナー知識の最小単位。**

FAQは「聞かれたことに答える」ためのデータ。
chunkは「その人らしく安全に話す」ための材料データ。

---

## 現行テーブル定義（Layer2 retrieval chunk）

```
chunk_id       例：ikeshiro_owner_001
owner_id       例：seesar_chui_ikeshiro_yasushi
store_id       例：seesar_chui
retrieval_topic 主題ラベル（下記の値のみ使用）
retrieval_scene 検索用途場面（下記の値のみ使用）
title          人が読んで意味が分かる短いタイトル
chunk_text     RAG検索用の本文（自然文・短段落）
retrieval_text 検索用短語（固有名詞・重要語）
confidence     根拠の強さ（0.0〜1.0）
source_types   素材種別のJSON配列（例：["interview","survey"]）
source_refs    元データ参照のJSON配列
notes          運用メモ
is_active      true固定
```

---

## retrieval_topic（使う値のみ）

```
profile           経歴・役職・立場
persona           人物像・性格傾向・話し方
hobbies           趣味・嗜好・普段の過ごし方
values            価値観・何を大事にしているか
decision_making   判断基準・意思決定の考え方
personal_experience エピソード・転機・葛藤
owner_view_on_work  仕事観・品質観
owner_view_on_products 商品・製法・サービスへの見方
owner_view_on_place 地域・体験・現地への見方
```

## retrieval_scene（使う値のみ）

```
self_intro      自己紹介・プロフィール質問向け
persona_question 人物像・趣味・性格質問向け
grounded_answer  価値観・判断基準の回答向け
related_info    近接情報として補助的に使う
general_support  一般論補助として使う
```

---

## カラム別の作成ルール

### chunk_text（最重要）
- 自然文または短段落
- **オーナー本人が主語・主役**
- 設問文・回答日時・フォーム記号を含めない
- 会話制御ルール（「ですます調で話す」「確認してから答える」等）を含めない
- ブランド一般説明・商品一般説明・業界説明は含めない
- 1件1主題

### title
- 必ずオーナー本人主語にする
- 例：「{オーナー名}の経歴と代表としての立場」
- 固有名詞は①〜③準拠の漢字表記を使う

### retrieval_text
- 検索用短語のみ
- オーナー名＋人物像/趣味/価値観/判断基準/経験の核語を優先
- 質問文コピー禁止
- 会話制御語禁止

### confidence
- アンケート明示回答・本人発話：0.90〜0.99
- 対面インタビューで語った内容：0.85〜0.95
- 曖昧・間接的な内容：0.60〜0.80

### source_types の値
```
survey    アンケート回答（①②③）
interview 対面インタビュー（④）
json      persona JSONファイル
txt       テキスト資料
```

---

## 残してよい内容 / 外すべき内容

### 残してよい例
- 「○○は20XX年に入社し、20XX年から代表を務めている」
- 「○○は挑戦的で遊び心があり大胆な性格で〜と語っている」
- 「LINEスタンプを自分で作ることと漫才を見ることが楽しみだと語っている」
- 「嘘をつかず、短期より長期の信頼を重視する」
- 「情報不足時は性急に決めず、根拠と確認を重視する」

### 外すべき例
- 「ですます調で話す」→ 会話制御
- 「確認してから答える」→ 会話制御
- 「この店は○○年創業である」→ ブランド一般説明（本人主語でないなら除外）
- 「泡盛は全麹仕込みが特徴である」→ 業界一般説明

---

## 静的監査チェックリスト（出力前に必ず確認）

1. chunk_textの主役はオーナー本人か
2. 固有名詞が①〜③準拠になっているか
3. 会話制御ルールが混ざっていないか
4. ブランド・商品・業界の一般説明だけになっていないか
5. 1chunk1主題になっているか
6. 設問文・回答日時・メタ情報が混ざっていないか
7. retrieval_topicは妥当か（定義外の値を使っていないか）
8. retrieval_sceneは妥当か（定義外の値を使っていないか）
9. titleはオーナー本人主語になっているか（固有名詞は①〜③準拠か）
10. source_refsで後追い検証できるか
11. owner_id・store_idが全行入っているか（①〜③準拠の表記か）
12. IDが連番で欠落・衝突がないか

---

## Layer2生成プロンプト

```
あなたは「オーナーAI向けretrieval chunk生成エンジン」です。

入力として以下を受け取ります。
- ①基盤アンケート
- ③性格補完アンケート（FFPQ）
- ④対面インタビュー文字起こし
- （あれば）②FAQアンケート
- store_id / owner_id（①〜③準拠で確定済みのもの）

最初に必ず以下を①〜③から確定してください。
□ オーナー名（漢字・読み仮名）→ title・chunk_textに使用
□ オーナー姓のローマ字 → chunk_idプレフィックスに使用
□ owner_id
④と食い違う場合は①〜③を採用する。

絶対ルール：
1. ハルシネーション禁止。素材にない事実は一切書かない。
2. 推測禁止。曖昧なら除外する。
3. 固有名詞・漢字・読み仮名は①〜③準拠。④で異なる表記が出ても①〜③を採用する。
4. 設問文・回答日時・フォーム記号・見出し・メタ情報を本文に残さない。
5. 1chunkに複数の主題を入れない。
6. オーナー本人が主役でないchunkは作らない。
7. 会話制御ルールはchunkにしない。
8. ブランド一般説明・商品一般説明・業界説明のみのchunkは作らない。
9. ③単独ではchunkにしない（④で補完がある場合のみ）。
10. is_activeはtrue固定。
11. 出力はCSVのみ。説明文・補足コメントは不要。

優先的に作るretrieval_topic：
profile / persona / hobbies / values / decision_making / personal_experience / owner_view_on_work

必ず抽出するもの（素材にあれば）：
- 事業を始めた・継いだ経緯とエピソード
- 価値観・何を大事にしているか
- 分からない・情報不足時の判断姿勢
- 緊張時の反応・慎重さの表れ方
- 趣味・普段の過ごし方
- 誠実さ・誠実さのエピソード
- 仕事を続けてきた理由・やめなかった理由

出力形式（CSV）：
chunk_id,owner_id,store_id,retrieval_topic,retrieval_scene,title,chunk_text,retrieval_text,confidence,source_types,source_refs,notes,is_active
```

---

## 高橋商店15件のretrieval_topic分布（参考目安）

```
profile          1件
personal_experience 3件
values           1件
decision_making  2件
owner_view_on_products 1件
owner_view_on_work 4件
persona          2件
hobbies          2件
合計 15件
```

新店舗でもこの分布を参考に網羅性を確認すること。
