# convert2skk/ ディレクトリ

## はじめに

SKK 辞書以外のものから SKK 辞書に変換するためのスクリプト群です。


## 各スクリプトの説明

* `prime2skk.rb` prime-dict を SKK 化
* `ipadic2skk.rb` IPADIC (ver. 2.7.0以降) を SKK 化

* `chasen2skk.rb` ChaSen の出力を SKK 化
* `skk-wordpicker.rb` 各種テキストを KAKASI で SKK 化
* `naozora2skk.rb` 青空文庫から SKK 辞書を作成
* `doc2skk.sh` 以上３つのフロントエンド

### prime2skk.rb

[予測入力システム PRIME](http://taiyaki.org/prime/) の辞書である prime-dict を SKK 形式に変換します。

```
#!/bin/sh
prime2skk.rb -gA prime-dict > prime-dict.skk
conjugation.rb -UCop prime-dict.skk > prime-dict-conj.skk
skkdic-expr2 prime-dict.skk + prime-dict-conj.skk | annotation-filter.rb -k > SKK-JISYO.prime
```

273433 candidates の、きちんと okuri-ari も持っている SKK 辞書が作成さ
れます。prime-dict は L 辞書がベースの一つになっていることもあり、L 辞書と
の重なりを除くと 41491 candidates になります。

なお、prime-dict のライセンスはGPLです。

### ipadic2skk.rb

[形態素解析システム茶筅](http://chasen.naist.jp/hiki/ChaSen/)の辞書 IPADIC を SKK 形式に変換します。
2.7.0以降のバージョンにしか対応していないのでご注意ください。

```
#!/bin/sh
ipadicpath=/path/to/ipadic-2.7.0
ipadic2skk.rb -gA $ipadicpath/*.dic > SKK-JISYO.ipadic.raw
conjugation.rb -op SKK-JISYO.ipadic.raw | skkdic-expr 2 > SKK-JISYO.ipadic.conj
complete-numerative.rb SKK-JISYO.ipadic.raw | skkdic-expr2 > SKK-JISYO.ipadic.num
skkdic-expr2 SKK-JISYO.ipadic.raw + SKK-JISYO.ipadic.conj + SKK-JISYO.ipadic.num | a
nnotatio
n-filter.rb > SKK-JISYO.ipadic
```

こちらは 225340 candidates の辞書になります。L辞書との重なりを除いても
152140 candidates あります。

ただし、固有名詞の類がかなり多いので、実際には

```
ipadic2skk.rb $ipadicpath/Noun.name.dic > SKK-JISYO.ipadic.jinmei
ipadic2skk.rb $ipadicpath/Noun.org.dic $ipadicpath/Noun.proper.dic > SKK-JISYO.ipadi
c.proper
noun
ipadic2skk.rb $ipadicpath/Noun.place.dic > SKK-JISYO.ipadic.geo
```

と専門辞書として取り出した方が有用でしょう。

|                             | candidates | SKK 辞書との重なりを除いた数
|-----------------------------|------------|-------
| SKK-JISYO.ipadic            |     225340 | 152140
| SKK-JISYO.ipadic.jinmei     |      30758 |  12989 
| SKK-JISYO.ipadic.geo        |      71494 |  18548
| SKK-JISYO.ipadic.propernoun |      40027 |  34807

なお、IPADIC のライセンスは ICOT ライセンスであり、このスクリプトで
IPADIC から変換した辞書にも ICOT ライセンスが適用されると思われます。

個人で利用なさる分には気になさる必要はありませんが、SKK で配布し
ている辞書に追加するなどの場合には注意が必要です。

### doc2skk.sh

読みのついていない平文から語彙を抽出し、読みを推測して SKK 辞書に
変換するスクリプトです。

ファイル、URL (-u) のいずれかを読み込み、またはキーワード (-w) をウ
ェブで検索して、他の３つのスクリプトに適宜渡して SKK 辞書形式で出
力します。L 辞書との重複も取り除きます。

以下のものが必要になります。パスが通るように適宜スクリプトを変更
してください（$converterpath など）。

* ChaSen, MeCab, KAKASI のいずれか一つ
* qkc か nkf
* w3m （lynx などでも代用可）
* skkdic-expr2
* skkdictools.rb

具体例に即して説明します。

```
% doc2skk.sh some.txt more.txt text.txt > result.txt
```

一番基本的な使い方です。テキストファイルを ChaSen で解析し、SKK
辞書形式に切り出して出力します。

```
% doc2skk.sh -m -w '音楽' > result.txt
```

サーチエンジン（標準では goo を使用しています）で「音楽」を検索し、
検索結果のページを MeCab で解析します。かなり遊べます。

`-w` の代わりに `-W` を指定すると、「音楽」を含む語のみを抽出します。

```
% doc2skk.sh -e k -u 'http://www.bookshelf.jp/texi/elisp-manual-20-2.5-jp/elisp_toc.html' > SKK-JISYO.elisp
```

`-u` で指定した URL を直接（w3mで）開き、MeCab で解析します。
（なかなか良い elisp 用語辞書が出来ます。）

読み＝見出しの決定に使用するプログラムはオプションで指定できます。

* `-a` テキスト自体のルビを利用（青空文庫仕様）
* `-c` ChaSen
* `-m` MeCab
* `-k` KAKASI

`-e` オプションを変換用スクリプトに渡します。`-e k` で `-k` が渡ります。

### chasen2skk.rb

ChaSen または MeCab （ChaSen 互換モード）の出力を読み、SKK のペア
を出力します。

```
% chasen | chasen2skk.rb
% mecab -Ochasen | chasen2skk.rb
```

として、いろいろと入力してみると動作の様子がよくわかると思います。


独自のオプションとして次のものがあります。
（doc2skk.sh からも `-e` オプションを介して指定できます）

* `-k` カタカナ語ペアを生成する（あいすぴっく /アイスピック/）
* `-n` ChaSen の出力する文法情報を annotation として添付する
* `-w` 指定した単語を含む語彙のみ生成する

どうせなら `-k` で本式の abbrev ペアを作れれば良かったのですが、カ
タカナ語から機械的に原綴を生成する手段は思い付けませんでした。残念。

;; MeCab をインストールしたら是非これも試してみましょう。
;; http://chasen.org/~taku/software/mecab-skkserv/

### skk-wordpicker.rb

chasen2skk.rb と同様ですが、形態素解析器の代わりに KAKASI を使用
します。

chasen2skk.rb のオプション knw の他に次の二つがあります。

* `-g` goo のヒット数を annotation として付加します。（非推奨）
* `-K` カタカナと漢字の混じった語彙を生成します。

### aozora2skk.rb

青空文庫、またはそれと類似の形式でルビを振ってある文章から SKK 
辞書を生成します。中身は一行野郎です。

	　宗助（そうすけ）は先刻（さっき）から縁側（えんがわ）へ坐
	蒲団（ざぶとん）を持ち出して、日当りの好さそうな所へ気楽に
	胡坐（あぐら）をかいて見たが、やがて手に持っている雑誌を放
	り出すと共に、ごろりと横になった。

```
% aozora2skk.rb kusamakura.txt | skkdic-expr2 > kusamakura.skk
```

あるいは

```
% doc2skk.sh -a 'http://www.aozora.gr.jp/cards/000148/files/776_14941.html' > kusamakura.skk
```

有用な例：

	うきよこうじ /浮世小路/
	おしょうさま /和尚様/
	おらてがま /遠良天釜/
	じょうごう /定業/
	じれ /焦慮/

ノイズの例：

	あいかえり /二三子相顧;ルビがどこまでかかるかわからない！/
	あるい /歩行;用言は全滅です/

今から漱石について書くぞ！　という時にこれで下拵えしておくと多少
楽ができるかもしれません。

## 限界

これらの試みは、読みの決定と入力単位の判断という厄介な問題を扱う
ことになります。

形態素解析器のチューニングと辞書の増強である程度は性能を改善でき
る可能性はありますが、ある程度人間の手を入れないと実用にならないの
は仕方のないところです。

短い未知語に正しい読みがつけられる望みはほとんどありません。
人名も苦手です。

	かたりちゅう /語注;{かたり->ご}ちゅう/
	わたなべこうづび /渡辺香津美/

ipadic は連濁に関する情報を持っていないので、生成される読みも当
然一切連濁してくれません。

	がらすたな /ガラス棚;がらす{た->だ}な/

　;; EDR には連濁の情報があるのですが、120万円×8では……（苦笑）


基本的な語彙に関しては、SKK 辞書は ipadic よりも少々粒が揃ってい
ます（エッヘン）。結果、解析能力では遥かに劣るはずの KAKASI の方が
賢い読みを提供してくれるケースもあります。

	こうぶんきじゅつこ /構文記述子;ChaSen,MeCab/
	こうぶんきじゅつし /構文記述子;KAKASI/
	どうひとかつどう /同人活動;ChaSen,MeCab/
	どうじんかつどう /同人活動;KAKASI/

L 辞書や人名辞書などを ipadic 化すると機能を向上させられるかもし
れません。品詞情報をどうするかは頭痛のタネですが。

語の切れ目の解析は実にいい加減です。特に、サーチエンジンを利用し
た場合、かなりろくでもないペアも生成されます。（形態素解析器は文法
情報を出力してくれいているので、これはスクリプト側で改善の余地があ
るかもしれません）

	おんがくにゅーすいちらんあさひしんぶん /音楽ニュース一覧朝日新聞/
	かいちょさくけんはんれいけんきゅうかい /回著作権判例研究会/

ひらがな混じりの複合語には全く対応できません。
用言（okuri-ari）の生成もほとんど期待できません。

	あるきとおs /歩き通/
	まよいみち /迷い道/

## 建設的な使い方

上で見たように、出力結果はお世辞にも高品質とは言いがたいですが、
それでも有用な複合語も多数生成されます。

### ニーズに応じた複合語増強

各自が専門としている分野や興味・関心のある分野に関する文章やサイ
トを対象に抽出を行うことで、その分野で使われる複合語をある程度補っ
てやることができます。

```
% doc2skk.sh -u http://www.houko.com/00/01/S45/048.HTM > chosakuken.skk
```

これは「法庫」サイト提供の「著作権法」全文の URL です。この処理
から生成される次のようなペアは、著作権に関わる文章を書く時にはかな
りの助けになってくれることでしょう。

	かんらんしゃ /観覧者/
	かんれんじぎょうしゃ /関連事業者/
	きょうどうちょさくけん /共同著作権/
	きょうりょくぎむ /協力義務/
	けっていしょ /決定書/
	こうじゅつけん /口述権/
	さいほうそうけん /再放送権/
	まらけしゅきょうてい /マラケシュ協定/

無論、ノイズも多数混じりますが、L 辞書やユーザ辞書に加えるのでは
なく、わかった上で複数辞書の一つとして使う分にはそれほど問題にはな
らないでしょう。

	けんりさいしょ /権利最初/
	じょうさくじょ /条削除/
	そうしんかのうかつぎ /送信可能化次/
	まいとしさだめる /毎年定める/

```
% doc2skk.sh -w 著作権 >> chosakuken.skk
```

とすることで、著作権に関するもう少し幅の広い語彙を集めることもで
きます。

	どうひとかつどう /同人活動;直して使いましょう（笑）/
	ひごうほうか /非合法化/
	ふりーそふとうぇあざいだん /フリーソフトウェア財団/
	ぶんかぎょうせい /文化行政/


質の高いソースを用意した上で、完璧を期待せず、出力を適宜手直しし
て使ってやればそこそこ実用的なものになるのではないかと思っています。

### 辞書の自動生成・成長

生成された語彙を、（例によって）サーチエンジンのヒット数で篩にか
けてやれば、比較的有用なものだけを残してやることができそうです。読
みの修正は人間がせねばなりませんが、語彙として明らかにおかしいもの
は他の低頻度な語彙と一緒に篩い落としてやれるでしょう。

これらを、ウェブ上をクロールするプログラムと組み合わせてやること
で、高頻度な複合語をある程度効率良く揃えてやることができるのではな
いかと考えています。


また、chasen2skk.rb に `-n` （または doc2skk.sh に `-e n`）をつけ
れば、解析器の出力する文法情報を付加してやることができます。これは
notes 辞書に転用できますし、やり方によっては SKK 以外にも使えるデー
タを作り出せるかもしれません。

	こうじゅつろうどく /口述朗読;‖<autogen>,名詞-サ変接続/

## 著者

三田祐介 < clefs<span></span>@mail.goo.ne.jp >
