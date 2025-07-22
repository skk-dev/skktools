skktools [![Build Status](https://travis-ci.org/skk-dev/skktools.svg)](https://travis-ci.org/skk-dev/skktools)
=====

SKK 辞書のメンテナンスや拡張に必要なツールを集めたパッケージです。

## 各ディレクトリについて

### トップディレクトリ

C で書かれたツール。READMEs ディレクトリに収めてある README.* もご覧ください。

* `skkdic-count` 辞書の中の候補数を数える
* `skkdic-diff` ふたつの辞書の差分を真鵺道形式で出力
* `skkdic-expr` 複数の辞書のマージなど
* `skkdic-expr2` skkdic-expr の高速版
* `skkdic-sort` 辞書のソート
* `skk2cdb.py` SKK 形式から cdb 形式への変換
* `saihenkan.rb` バージョン 2.1.0 以降の ruby が必要

### READMEs ディレクトリ

* `FAQ.txt`
* `README.C` skkdic-expr, skkdic-sort 及び skkdic-count の解説
* `README.skkdic-diff`
* `README.skkdic-expr2`

### convert2skk ディレクトリ

SKK 以外の辞書を SKK 形式に変換するために使用するプログラム。

* `aozora2skk.rb` 青空文庫から SKK 辞書を作成
* `chasen2skk.rb` ChaSen の出力を SKK 化
* `ipadic2skk.rb` IPADIC (ver. 2.7.0以降) を SKK 化
* `prime2skk.rb` prime-dict を SKK 化
* `skk-wordpicker.rb` 各種テキストを KAKASI で SKK 化

### dbm ディレクトリ

SKK 辞書を dbm 化するために使用するプログラム。pskkserv の一部。

### filters ディレクトリ

SKK 辞書を加工・編集するために使用するプログラム。

* `abbrev-convert.rb`
* `abbrev-simplify-keys.rb`
* `annotation-filter.rb`
* `asayaKe.rb`
* `complete-numerative.rb`
* `conjugation.rb`
* `make-tankan-dic.rb`
* `skkdictools.rb`

上記は Ruby スクリプトであり、バージョン 2.1.0 以降の ruby が必要です。

## ビルド方法

トップディレクトリに置かれているプログラムについては、下記の手順でビルド・インス
トールできます。

```
$ ./bootstrap
$ ./configure
$ make
$ make install
```

ビルドには libdb-devel パッケージ (Berkeley DB library) が必要です。

```
$ dnf install libdb-devel
```
```
$ sudo apt install libdb-dev
```

他のディレクトリについては、必要に応じてそれぞれのディレクトリを参照してください。

Mikio Nakajima/中島幹夫 < minakaji<span></span>@osaka.email.ne.jp >
