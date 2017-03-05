skktools [![Build Status](https://travis-ci.org/skk-dev/skktools.svg)](https://travis-ci.org/skk-dev/skktools)
=====

SKK 辞書のメンテナンスや拡張に必要なファイルを集めたパッケージです。

## 各ディレクトリについて

### トップディレクトリ

C で書かれたツール。READMEs ディレクトリに収めてある README.* もご覧ください。

* `skkdic-expr` 複数の辞書のマージなど
* `skkdic-expr2` skkdic-expr の高速版
* `skkdic-sort` 辞書のソート
* `skkdic-count` 辞書の中の候補数を数える
* `skkdic-diff` ふたつの辞書の差分を真鵺道形式で出力

### convert2skk ディレクトリ

SKK 以外の辞書を SKK 形式に変換するために使用するプログラム。

* `prime2skk.rb` prime-dict を SKK 化
* `ipadic2skk.rb` IPADIC (ver. 2.7.0以降) を SKK 化
* `chasen2skk.rb` ChaSen の出力を SKK 化
* `skk-wordpicker.rb` 各種テキストを KAKASI で SKK 化
* `aozora2skk.rb` 青空文庫から SKK 辞書を作成

### dbm ディレクトリ

SKK 辞書を dbm 化するために使用するプログラム。pskkserv の一部。

### filters ディレクトリ

SKK 辞書を加工・編集するために使用するプログラム。

## ビルド方法

トップディレクトリに置かれているプログラムについては、下記の手順でビルド・インス
トールできます。

```
$ ./configure
$ make
$ make install
```

ビルドには gdbm-devel パッケージ (GNU database indexing library) が必要です。

```
$ dnf install gdbm-devel
```

他のディレクトリについては、必要に応じてそれぞれのディレクトリを参照してください。

Mikio Nakajima/中島幹夫 < minakaji<span></span>@osaka.email.ne.jp >
