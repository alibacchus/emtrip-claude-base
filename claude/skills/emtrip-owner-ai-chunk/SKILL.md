---
name: emtrip-owner-ai-chunk
description: EmTripのオーナーAI横展開用chunk生成スキル。新店舗のアンケート回答・インタビュー文字起こしからchunk_master投入用CSVを生成する。「chunkを作って」「オーナーのchunkを作って」「インタビューからchunkを」「人物chunkを作って」などの指示で必ず使うこと。chunk_master/chunk_embeddingsのSupabase投入用データ生成にも使う。
---

# EmTrip オーナーAI chunk生成スキル v2

## このスキルの目的

新店舗のアンケート回答・インタビュー文字起こしから、**Supabase chunk_masterに直接投入できるCSV**を生成する。

高橋商店の15件（nakagawa_owner_001〜015）を品質基準として、同水準のchunkを一撃で作る。

詳細ルール・プロンプト・サンプルは参照ファイルを読むこと：
- `references/chunk_rules.md` — カラム定義・絶対ルール・プロンプト
- `references/chunk_examples.md` — 高橋商店の実データ全15件

---

## 【最重要】固有名詞の取り扱いルール

**①基盤アンケート・②FAQアンケート・③性格補完アンケートが最も正確な情報源。**

- オーナー名・店舗名・地名・会社名は、必ず①〜③のCSVに記載された表記を正とする
- ④対面インタビュー文字起こしは内容の参考にはするが、固有名詞・漢字・読み仮名は①〜③に従う
- ①〜③と④で食い違いがある場合は、必ず①〜③を採用する
- chunk_textとtitleのオーナー名・固有名詞は全て①〜③準拠で統一する

---

## 現行テーブル定義（Layer2 retrieval chunk・変えない）

```
chunk_id, owner_id, store_id, retrieval_topic, retrieval_scene,
title, chunk_text, retrieval_text, confidence,
source_types, source_refs, notes, is_active, created_at, updated_at
```

**Layer1（knowledge unit）は将来フェーズ・現状未実装。今回はLayer2のみ生成。**

---

## 実行フロー（必ずこの順で行う）

### Step 0｜固有名詞の確定（最初に必ず実行）

①〜③のCSVから以下を確定してメモする。確定前にchunk生成を開始してはならない。

```
□ オーナー名（漢字・読み仮名）→ owner_idとtitleに使用
□ オーナー名のローマ字 → chunk_idプレフィックスに使用
□ 店舗名
□ 会社名
□ store_id
□ owner_id（例：seesar_chui_ikeshiro_yasushi）
```

### Step 1｜素材の確認

- ①基盤アンケート / ③性格補完アンケート / ④インタビュー文字起こし を読む
- （あれば）②FAQアンケートも参照

### Step 2｜事実候補の抽出

`references/chunk_rules.md`のLayer2生成プロンプトを読んで実行すること。

以下を優先して抽出する：
- プロフィール・経歴・立場
- 人物像・性格傾向・自己認識
- 趣味・嗜好・普段の過ごし方
- 価値観・判断基準・何を大事にしているか
- エピソード・転機・葛藤
- 仕事観・商品や体験への見方
- 緊張の出方・慎重さの表れ方

### Step 3｜Owner Anchor Test

各候補について「オーナー本人が主役か」を判定する。

以下のいずれかを満たす場合のみ残す：
- A. オーナー本人の経歴・立場・履歴を直接述べている
- B. オーナー本人の性格・人物像・好みを直接述べている
- C. オーナー本人の価値観・判断基準・姿勢を直接述べている
- D. オーナー本人の経験・葛藤・転機・エピソードを直接述べている
- E. オーナー本人が自分の商品・仕事・地域をどう見ているかを述べている

以下は除外：
- ブランド一般説明のみ
- 商品一般説明のみ
- 業界一般説明のみ
- 会話制御ルール（「ですます調で話す」等）

### Step 4｜静的監査

`references/chunk_rules.md`のチェックリストを使用。

### Step 5｜CSV出力・ファイル書き出し

監査OKの行のみをCSVとして指定パスに書き出す。

---

## IDの採番ルール

```
{オーナー姓ローマ字}_owner_{連番3桁}
例：ikeshiro_owner_001, ikeshiro_owner_002 ...
```

オーナー姓ローマ字は①〜③のCSVから確認したもので設定する。

## CSVカラム順（変えない）

```
chunk_id,owner_id,store_id,retrieval_topic,retrieval_scene,title,chunk_text,retrieval_text,confidence,source_types,source_refs,notes,is_active
```

## retrieval_topic（使う値のみ）

```
profile / persona / hobbies / values / decision_making /
personal_experience / owner_view_on_work /
owner_view_on_products / owner_view_on_place
```

## retrieval_scene（使う値のみ）

```
self_intro / persona_question / grounded_answer / related_info / general_support
```

---

## 絶対ルール（全ステップ厳守）

1. **固有名詞は①〜③準拠** — ④で違う表記が出ても①〜③を採用する
2. **ハルシネーション禁止** — 素材にない事実は一切書かない
3. **推測禁止** — 曖昧なら除外する
4. **オーナー本人が主役** — ブランド/商品/業界の一般説明のみのchunkは除外
5. **会話制御は含めない** — 「ですます調で話す」等の制御ルールはchunkにしない
6. **1chunk1主題** — 複数の意味を1件に入れない
7. **③単独不可** — FFPQのみでchunkにしない（④で補完があるもののみ）
8. **is_active** — true固定

---

## 完了後の確認事項

- [ ] Step 0で確定したオーナー名が全行で統一されているか
- [ ] owner_idが全行正しく入っているか
- [ ] store_idが全行正しく入っているか
- [ ] IDが連番で欠落・衝突がないか
- [ ] 高橋商店15件の retrieval_topic 分布と比べて明らかに不足している主題がないか
- [ ] 素材不足で作れなかった主題を報告したか
