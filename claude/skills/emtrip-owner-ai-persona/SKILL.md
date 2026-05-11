---
name: emtrip-owner-ai-persona
description: EmTripのオーナーAI横展開用persona_message JSON生成スキル。新店舗のアンケート回答・インタビュー文字起こしからSupabase Storageに配置するpersona_message JSONを生成する。「persona JSONを作って」「ペルソナメッセージを作って」「persona_messageを作って」「オーナーAIのJSONを作って」などの指示で必ず使うこと。
---

# EmTrip オーナーAI persona_message JSON生成スキル v2

## このスキルの目的

新店舗のアンケート回答・インタビュー文字起こしから、**Supabase Storageのapp-configバケットに配置するpersona_message JSONファイル**を生成する。

詳細ルール・構造定義は参照ファイルを読むこと：
- `references/persona_rules.md` — 構造定義・各項目のルール・プロンプト・FFPQの使い方
- `references/persona_examples.md` — 高橋商店の実データサンプル

---

## 【最重要】固有名詞の取り扱いルール

**①基盤アンケート・②FAQアンケート・③性格補完アンケートが最も正確な情報源。**

- オーナー名・店舗名・地名・会社名・役職は、必ず①〜③のCSVに記載された表記を正とする
- ④対面インタビュー文字起こしは内容の参考にはするが、固有名詞・漢字・読み仮名は①〜③に従う
- ①〜③と④で食い違いがある場合は、必ず①〜③を採用する
- systemメッセージのオーナー名・店舗名・地域は①〜③準拠で設定する

---

## ファイル構造（変えない）

```json
[
  { "role": "system", "content": "ペルソナ設定" },
  { "role": "user",      "content": "質問1" },
  { "role": "assistant", "content": "回答1" },
  ...
]
```

- system：1件のみ
- user/assistantペア：15件前後
- 合計：31件前後

---

## 実行フロー

### Step 0｜固有名詞の確定（最初に必ず実行）

①〜③のCSVから以下を確定してメモする。確定前にJSON生成を開始してはならない。

```
□ オーナー名（漢字・読み仮名）→ systemメッセージ・assistantに使用
□ 店舗名
□ 会社名・法人形態
□ 役職
□ 所在地（都道府県・市区町村・施設名）
□ store_id
□ 出力ファイル名（例：seesar_chui_owner_ai_persona_message.json）
```

### Step 1｜素材の確認

①基盤アンケート / ②FAQアンケート / ③性格補完アンケート / ④インタビュー文字起こし

### Step 2｜systemメッセージの作成

`references/persona_rules.md`の「systemメッセージ必須要素①〜⑩」を全て含める。
固有名詞は全て①〜③準拠の表記を使う。

### Step 3｜Q&Aペアの作成（15ペア前後）

`references/persona_rules.md`の「必須カバー質問15項目」を素材の範囲で網羅する。
素材にない質問項目は作らない。assistantは全て一人称で書く。

### Step 4｜静的監査

`references/persona_rules.md`の静的監査チェックリストを使用。

### Step 5｜JSON出力・ファイル書き出し

有効なJSON形式で指定パスに書き出す。

---

## 絶対ルール

1. **固有名詞は①〜③準拠** — ④で違う表記が出ても①〜③を採用する
2. **ハルシネーション禁止** — 素材にない事実は一切書かない
3. **推測禁止** — 曖昧なら反映しない
4. **一人称厳守** — assistant回答は常にオーナー本人の一人称
5. **AIの第三者視点禁止** — 「AIとして」「データによると」等の表現禁止
6. **③単独不可** — FFPQのみでQ&Aを作らない（④で補完がある場合のみ使う）
7. **禁止語** — 素材から確認した禁止語をsystemに必ず入れる
8. **推奨語** — 素材から確認した推奨語をsystemに必ず入れる

---

## 完了後の確認事項

- [ ] Step 0で確定した固有名詞がsystemメッセージに正しく入っているか
- [ ] systemメッセージに必須要素①〜⑩が全て入っているか
- [ ] 15ペア前後のQ&Aが揃っているか
- [ ] 全assistantがオーナー本人の一人称で書かれているか
- [ ] 素材に根拠がないQ&Aが混じっていないか
- [ ] 有効なJSON形式になっているか（python3 -c "import json; json.load(open('ファイル名'))"で確認）
