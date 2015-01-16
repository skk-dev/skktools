;; -*- text -*-

C 言語で書かれた SKK 辞書のユーティリティです。複数の SKK 辞書を結合し
たりその差を取ることができます。同様のプログラムで辞書が巨大すぎて 
mule や nemacs がパンクしたり、実行時間がかかりすぎる時に試してみてく
ださい。

				高橋 裕信     takahasi@tiny.or.jp
				佐藤 雅彦     masahiko@kuis.kyoto-u.ac.jp
				薮内 健二     yab@kubota.co.jp
				酒井 清隆     ksakai@kso.netwk.ntt-at.co.jp

◎ プログラム作成方法

作成キットに含まれるシェルスクリプト "configure" を実行して Makefile 
を作成します。次に make を実行すれば 3 つの実行ファイルが作成されます。

・ configure については ./configure --help とすれば使用できるオプショ
   ンが表示されます。

・ skkdic-expr は辞書の 2 倍程度の大きさの作業用ファイルを作成します。
   このファイルが作成されるディレクトリは実行時に指定できますが、デフォー
   ルトとして "/tmp" を指定しています。もしも明らかに不足する場合には 
   Makefile 中で -DTMPDIR=\".\" のように DEFS に指定すると、/tmp が溢
   れるといった災害を防止できます。

・ 扱う辞書の行が 4096 バイトに近いかそれ以上になる場合は、Makefile の
   DEFS に書かれた MAXLEN を大きくして再コンパイルしてください。

◎ プログラムの説明

1. skkdic-expr

   複数の SKK 辞書をマージしたり、他の辞書と同じ内容を引くのに使いま
   す。次のようにして使います。

   skkdic-expr jisyo1 + jisyo2 - jisyo3 + jisyo4 > result

   これは、まず jisyo1 に jisyo2 を加えます。もしも jisyo2 に同じエン
   トリがあれば重複しては含まれません。次に jisyo3 と同じエントリがあ
   れば削除されます。さらに jisyo4 の内容が加えられた結果が標準出力に
   吐き出されます。

   また辞書に先行して次のオプションが使用できます。

   -d 作業用ディレクトリ  : デフォルト以外の作業ディレクトリを指定します。
   -o 出力ファイル        : 標準出力ではなくファイルに出力します。
   -O                     : [み/読/詠] の送りがなのエントリも残します。

   例題:

   a. 複数の辞書を cat でつないだものをきれいにする。

   このプログラムは辞書を読み込む時に同じエントリを一つにまとめたり、
   同じ読みが別々の行になっていてもまとめる機能を持っています。
   例えば次のような他の辞書を一行ごとのフォーマットに変換してから、さ
   らにまとめるのにも使用できます。優先順位は上から順になります。
   同じ読みの並び順を変更するのにも使えます。

じしょ /辞書/
じしょ /璽書/
じしょ /字書/

   skkdic-expr olddict1 > newdict1

   b. 個人辞書にある分だけを取り出す。

   skkdic-expr ~/.skk-jisyo - /usr/local/nemacs/etc/SKK-JISYO.L > private

   毎年 2 月頃を目途にアナウンスしますが, SKK辞書の充実にご協力いただける
   方は, 随時以下のアドレスまで個人辞書と SKK-JISYO.L との差分をお送りく
   ださい. お送りいただいた辞書を整理して次年度の辞書に含めさせていただき
   ます.

   また, SKK-JISYO.L の誤りを発見された方は多少にかかわらず, 下記
   のアドレスまでお知らせください.

        skk-jisyo@sato.riec.tohoku.ac.jp

   c. 2つの辞書の共通部分を取り出す。

   skkdic-expr jisyo-a - jisyo-b > jisyo-tmp
   skkdic-expr jisyo-a - jisyo-tmp > jisyo-common

2. skkdic-sort

   skkdic-expr はでたらめな順番で出力します。それを通常の SKK 辞書
   の形式にソートして、;; okuri-ari entry と ;; okuri-nasi entry を挿
   入します。入力は標準入力のみ、出力は標準出力のみが指定できます。

   例
   skkdic-expr jisyo-a + jisyo-b | skkdic-sort > newdict

3. skkdic-count

   SKK 辞書の中候補数を数えます。[] で囲まれた送りがなつきのブロックは
   候補としては数えない仕様になっています。

◎ 使用および再配布について

これらのプログラムは SKK と同じように Gnu General Public License (GPL)
(Version 2 もしくはそれ以降のもの) の下で自由に再配布したり修正して使
用することができます。もちろんこれらのプログラムはきっと役に立つと考え
ていますが、その内容については何らの保証もしません。正確な点については 
SKK に添付している COPYING というファイルに GPL が書かれているのでそち
らを参照してください。
