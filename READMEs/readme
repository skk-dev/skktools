● SKK辞書ユティリティ
￣￣￣￣￣￣￣￣￣￣￣
skktoolsはSKK辞書をマージしたりpubdic辞書をSKK辞書に変換したり
するためのツール群です。SKK辞書は読みに対応する複数の漢字が'/'
で区切られた構造をしていますが、このツールでは読みと漢字が１対
１に対応した形式（これをリスト形式と呼ぶことにします）のファイ
ルを中間形式として取り扱います。

 ○ skk2list	SKK辞書をリスト形式に変換します。
 ○ pubdic2list	pubdic辞書の名詞エントリをリスト形式に変換します。
 ○ list2skk	リスト形式をSKK辞書に変換します。
 ○ adddummy	SKK辞書ソートのためにダミー文字を加えます。
 ○ removedummy	加えたダミー辞書を取り除きます。

例えば既存のSKK辞書とpubdic辞書をマージして新しいSKK辞書を作成
するには次のように行ないます。

  % (skk2list skk-jisyo ; pubdic2list kihon.u) \ ; リスト形式を連結
	| adddummy \				 ; ダミー文字追加
	| sort -u \				 ; ソート
	| removedummy \				 ; ダミー文字削除
	| list2skk \				 ; SKK辞書に変換
	> skk-jisyo.new

これらのツールではEUCの辞書のみ取り扱い可能です。それ以外の
辞書を使うときは後述のjis2ujisなどのコマンドを加えて下さい。

● 差分の計算
￣￣￣￣￣￣￣
"sub"はふたつのファイルの差分を出力するコマンドです。skk辞書に新たに
加えられたエントリを抽出するには、新旧のskk辞書のリスト形式を用意し、

  % sub 旧リスト 新リスト

とします。比べられるふたつのファイルはあらかじめソートされていなければ
なりません。

● 漢字検索コマンド
￣￣￣￣￣￣￣￣￣￣
"skkconv"はskkサーバを使用してコマンドラインでかな漢字変換するための
コマンドです。例えば「かんじ」という読みをもつ漢字を以下のように
検索できます。

  % skkconv kanji
  漢字
  幹事
  感じ
  ......
  %

● ユティリティ
￣￣￣￣￣￣￣￣
以下のperlライブラリとコマンドはおまけです。

 ○ codeconv.pl		JIS,EUC,SJIS相互変換ライブラリ
 ○ roma2kana.pl	ローマ字→平仮名変換ライブラリ
 ○ kana2roma.pl	平仮名→ローマ字変換ライブラリ
 ○ jis2sjis		JIS→SJIS変換コマンド
    sjis2jis		SJIS→JIS変換コマンド
    jis2ujis		JIS→EUC変換コマンド
    ujis2jis		EUC→JIS変換コマンド
    roma2kana		ローマ字→かな(EUC)変換コマンド 
    kana2roma		かな(EUC)→ローマ字変換コマンド 

Perlライブラリ(*.pl)はperlのライブラリディレクトリに格納して
下さい。

● インストール方法
￣￣￣￣￣￣￣￣￣
perlの絶対パスをMakefile内で指定してmakeしてください。


増井俊之
カーネギーメロン大学機械翻訳センタ
masui@cs.cmu.edu

