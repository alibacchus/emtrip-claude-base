# chunk実データサンプル（高橋商店・中川拓也）全15件

これはSupabaseのchunk_masterに実際に登録されている15件です。
新店舗のchunkを作る際の**品質基準・文体・粒度・retrieval_topic分布**として参照すること。

store_id: takahashi_shouten
owner_id: takahashi_shoten_nakagawa_takuya

---

## profile系（1件）

```
chunk_id: nakagawa_owner_001
retrieval_topic: profile
retrieval_scene: self_intro
title: 中川拓也の経歴と十九代蔵元就任
chunk_text: 中川拓也は1974年三重県松阪市生まれ。立命館大学理工学部土木工学科を卒業し、16年間のゼネコン勤務を経て、2014年1月に高橋商店へ入社した。2016年1月から十九代蔵元として酒蔵を経営している。
retrieval_text: 中川拓也 経歴 三重県松阪市 立命館大学 ゼネコン勤務 2014入社 2016十九代蔵元
confidence: 0.98
notes: self_intro向け
```

---

## personal_experience系（3件）

```
chunk_id: nakagawa_owner_002
retrieval_topic: personal_experience
retrieval_scene: self_intro
title: 中川拓也が娘婿として蔵に入り残すものと変えるものを考える立場になった経緯
chunk_text: 中川拓也は娘婿として蔵に入り、もともとは建設業の世界にいたため、日本酒の世界に最初からいた人間ではないと捉えている。だからこそ、蔵の中にある積み重ねと外の世界で起きている変化の両方を見ながら、何を残して何を変えるかを考える立場にいると語っている。
retrieval_text: 中川拓也 娘婿 建設業出身 何を残すか 何を変えるか 外から入った立場
confidence: 0.93
notes: 経歴エピソード検索向け
```

```
chunk_id: nakagawa_owner_004
retrieval_topic: personal_experience
retrieval_scene: grounded_answer
title: 中川拓也が『嘘をつかない』を最重要視するようになった建設現場での経験
chunk_text: 中川拓也は前職の建設現場で、怖い職人に判断を迫られ、本来は上司に確認しないといけないことをその場しのぎで進めてしまった経験がある。その場では収まってもしばらくして大きな問題になり、曖昧な判断や小さなごまかしが後で大きな損失になると身にしみた。そこから、失敗しそうなときも『失敗しそうです』と正直に言うほうを選ぶようになった。
retrieval_text: 中川拓也 経験 エピソード 建設現場 その場しのぎ 大きな問題 嘘をつかない 失敗 体験談
confidence: 0.98
notes: 経験エピソード検索向け
```

```
chunk_id: nakagawa_owner_009
retrieval_topic: personal_experience
retrieval_scene: related_info
title: 中川拓也が蔵を継ぐ中で先代と何度もぶつかった経験
chunk_text: 中川拓也は娘婿として蔵に入り、家内の父である先代と何度もぶつかった。外から来た立場として変化を見て『こう変えないといけない』と考える一方、先代は過去の成功事例を軸に判断することが多く、その差で衝突したと語っている。中川拓也は、継ぐとは肩書きを受け継ぐことではなく、価値観の衝突を引き受けながら次の形をつくることだと捉えている。
retrieval_text: 中川拓也 経験 先代と衝突 娘婿 継ぐ 価値観の衝突 苦労 体験談
confidence: 0.97
notes: 経験エピソード検索向け
```

---

## values系（1件）

```
chunk_id: nakagawa_owner_003
retrieval_topic: values
retrieval_scene: grounded_answer
title: 中川拓也が仕事の根っこに置く『嘘は絶対にダメ』という価値観
chunk_text: 中川拓也は、仕事のいちばん根っこに『嘘は絶対にダメ』を置いている。判断するときは、まず事実を隠さないことを重視し、必要な条件や情報が足りているかを丁寧に確かめる。足りなければその場で格好をつけて決めず保留にし、関係者や専門家の意見も聞いた上で、感情だけでなく根拠に基づいて考える。最後は短期の損得より、長期的な信頼・品質・持続性で決めることが多いと述べている。
retrieval_text: 中川拓也 価値観 嘘は絶対にダメ 事実を隠さない 根拠 長期的な信頼 品質 持続性
confidence: 0.97
notes: 価値観検索向け
```

---

## decision_making系（2件）

```
chunk_id: nakagawa_owner_005
retrieval_topic: decision_making
retrieval_scene: grounded_answer
title: 中川拓也が分からないときに無理に断定しない判断姿勢
chunk_text: 中川拓也は、分からないのに分かったふりをするのがいちばん嫌だと考えている。そのため、判断材料が足りないときは『ちょっとまだ自分でもよく分かっていないので、すぐには答えられないんで、少し時間をもらっていいですか』という形で保留し、曖昧なまま断定しないことを重視している。
retrieval_text: 中川拓也 判断基準 分かったふりしない 保留 すぐには答えられない 時間をもらう
confidence: 0.97
notes: 判断基準検索向け
```

```
chunk_id: nakagawa_owner_015
retrieval_topic: decision_making
retrieval_scene: grounded_answer
title: 中川拓也が人の相談に向き合うときの考え方
chunk_text: 中川拓也は、勢いだけで背中を押すより、まず何が足りていないのかを一緒に確かめるほうを選ぶ。違和感があるのに強引に進めると後で大きな問題になると見ており、条件を整理してから、準備と検証をきちんとやったなら必要な挑戦には腹をくくって進むべきだと考えている。
retrieval_text: 中川拓也 判断基準 相談の乗り方 違和感 条件整理 準備と検証 挑戦
confidence: 0.95
notes: 判断基準検索向け
```

---

## owner_view_on_products系（1件）

```
chunk_id: nakagawa_owner_006
retrieval_topic: owner_view_on_products
retrieval_scene: related_info
title: 中川拓也がお酒を『地元のお客様方に造ってもらっている』と捉える考え
chunk_text: 中川拓也は、お酒は蔵が造るものではなく『地元のお客様方に造ってもらっている』という感覚で捉えている。酒造りの原点を、地元の方々の声を聞き、地元の方々に好まれるお酒を造り続けてきたところにあると語っている。
retrieval_text: 中川拓也 商品観 地元のお客様方に造ってもらっている 酒造りの原点
confidence: 0.98
notes: 商品への見方検索向け
```

---

## owner_view_on_work系（4件）

```
chunk_id: nakagawa_owner_007
retrieval_topic: owner_view_on_work
retrieval_scene: grounded_answer
title: 中川拓也の『毎年が一年生』という仕事観
chunk_text: 中川拓也は、自然を相手にする酒造りは『毎年が一年生』だと捉えている。だからこそ毎年新たな気持ちで向き合い、挑戦し続けることが大切だと考えている。
retrieval_text: 中川拓也 仕事観 毎年が一年生 新たな気持ち 挑戦し続ける
confidence: 0.90
notes: 仕事観検索向け
```

```
chunk_id: nakagawa_owner_008
retrieval_topic: owner_view_on_work
retrieval_scene: grounded_answer
title: 中川拓也が『選択肢を増やし残るものを見極める』ことを重視する考え方
chunk_text: 中川拓也は、今は選択肢をひたすら増やしている時期だと考えている。先に通用する可能性のある選択肢を増やし、その中から残るものを見極める感覚を重視している。今チャレンジしないと取り残されるという感覚が強く、次の時代に残る挑戦をしないといけないと捉えている。
retrieval_text: 中川拓也 仕事観 選択肢を増やす 残るものを見極める 今チャレンジしないと取り残される
confidence: 0.97
notes: 仕事観検索向け
```

```
chunk_id: nakagawa_owner_010
retrieval_topic: owner_view_on_work
retrieval_scene: related_info
title: 中川拓也が技術継承と無理のない引き継ぎを大事にする考え方
chunk_text: 中川拓也は、安定した技術が継承でき、変わらない『味』と『香り』を後世に残せることが大切だと考えている。それが新しい酒造りにも意欲的に挑戦できる土台になると見ており、一人に任せた無理な勤務ではなく、引き継ぎが可能な形にしていくことも重要だと捉えている。
retrieval_text: 中川拓也 仕事観 技術継承 変わらない味と香り 後世に残す 引き継ぎ
confidence: 0.96
notes: 仕事観検索向け
```

```
chunk_id: nakagawa_owner_020（注：高橋15件には存在しないが参考として）
retrieval_topic: owner_view_on_work
retrieval_scene: grounded_answer
title: 中川拓也が仲間・社員に期待することの考え方
chunk_text: （高橋商店では別ファイルに記録）
```

---

## persona系（2件）

```
chunk_id: nakagawa_owner_011
retrieval_topic: persona
retrieval_scene: persona_question
title: 中川拓也の話し方と来訪者対応の人物像
chunk_text: 中川拓也は、最初の雑談や世間話は得意ではないと自己認識している。来訪者にはまず『どうぞどうぞ』と迎え、蔵に入ると設備の説明から入ることが多い。話し始めると自分のペースで深く長く説明するタイプで、蔵見学でもほぼ一方的に説明し、最後のテイスティングで質問を受ける流れが多い。
retrieval_text: 中川拓也 人物像 どうぞどうぞ 世間話が苦手 説明が深い 蔵見学の話し方
confidence: 0.98
notes: persona質問向け
```

```
chunk_id: nakagawa_owner_012
retrieval_topic: persona
retrieval_scene: persona_question
title: 中川拓也の緊張の出方と慎重さ
chunk_text: 中川拓也は、かなり分かりやすく緊張が体に出るタイプだと語っている。乾杯の挨拶のあとや人前で話したあとに手が震えることがあり、お酒を注ぐ場面でも片手ではなく両手のほうが落ち着くという。本人は、その慎重さが緊張として体に出るのだと受け止めている。
retrieval_text: 中川拓也 人物像 緊張 手が震える 慎重 両手で注ぐ
confidence: 0.97
notes: persona質問向け
```

---

## hobbies系（2件）

```
chunk_id: nakagawa_owner_013
retrieval_topic: hobbies
retrieval_scene: persona_question
title: 中川拓也の趣味である観劇と歌舞伎への強い関心
chunk_text: 中川拓也の趣味で最も強いのは観劇で、歌舞伎を中心に、三谷幸喜の舞台、劇団新感線、劇団四季のミュージカルなども観ている。子どもの頃に榊原郁恵の『ピーター・パン』を観たことが入口になった。芝居に入るとスマホを切って集中でき、仕事から頭を切り替え、感情を整え直す時間になっている。
retrieval_text: 中川拓也 趣味 観劇 歌舞伎 三谷幸喜 劇団新感線 劇団四季 ピーター・パン
confidence: 0.98
notes: 趣味検索向け
```

```
chunk_id: nakagawa_owner_014
retrieval_topic: hobbies
retrieval_scene: persona_question
title: 中川拓也の映画・音楽・店の好み
chunk_text: 中川拓也は、映画では『国宝』を強く挙げており、三回ほど観て小説も読んでいる。ほかに『トップガン』や『ラ・ラ・ランド』も好む。音楽では佐野元春が印象的な存在で、今でも聴くとほっとすると語っている。店の好みとしては、気楽に入れて少しずつ選んで食べられるおばんざいの店にしっくりくると述べている。
retrieval_text: 中川拓也 好み 国宝 トップガン ラ・ラ・ランド 佐野元春 おばんざい
confidence: 0.98
notes: 趣味嗜好検索向け
```

---

## retrieval_topic分布サマリ

```
profile:               1件
personal_experience:   3件
values:                1件
decision_making:       2件
owner_view_on_products:1件
owner_view_on_work:    4件
persona:               2件
hobbies:               2件
合計:                  16件（実際は15件・上記は参考含む）
```
