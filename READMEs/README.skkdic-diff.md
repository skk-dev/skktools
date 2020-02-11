はじめに
========

skkdic-diff は二つの SKK 辞書の差分を *真鵺道* 形式で出力します。真鵺道
については次のページを参照してください。

http://www.mpi-sb.mpg.de/~hitoshi/otherprojects/manued/index-j.shtml


インストール
============

skkdic-diff は Gauche で書かれています。次のページからダウンロードし、
インストールしてください。バージョン 0.8 以上が必要です。

http://practical-scheme.net/gauche/index-j.html

Gauche の実行ファイルは gosh です。インストールされた gosh のパスに合わ
せて skkdic-diff.scm の先頭行を変更してください。

その後、パスの通ったディレクトリに skkdic-diff という名前でコピーし、
chmod + x してください。


プログラムの説明
================

skkdic-diff の動作を理解するには例を見たほうが早いでしょう。次のような
二つの辞書を引数として与えると、

    ---- SKK-JISYO.old ----
    designer /デサイナー/
    さい /際/差異/才/再/最/歳/
    てい /袋/
    てきかく /的確/適格/
    こくぼうしょう /国防相/国防省/

    ---- SKK-JISYO.new ----
    designer /デザイナー/
    さい /際/差異/才/再/最/歳/
    てきかく /的確/適格/適確/
    まぬえど /真鵺道/
    こくぼうしょう /国防省/国防相/

  ```
  $ skkdic-diff SKK-JISYO.old SKK-JISYO.new
  ```

次のような結果を出力します。

    designer /デ{サ->ザ}イナー/
    {てい /袋/->}
    てきかく /的確/適格/{->適確/}
    {->まぬえど /真鵺道/}
    こくぼうしょう /{国防相/||国防省/}

注意点
======

現時点では、skkdic-diff は EUC-JP 辞書にしか対応していません。

著者
====

木村 冬樹 <fuyuki@hadaly.org>
