#!/bin/sh
# Known Bugs; 加工した候補の後に SPC が入ってしまう。
#
sed -f wnn2skk.sed $@ | gawk -f wnn2skk.awk -
