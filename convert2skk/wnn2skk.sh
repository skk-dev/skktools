#!/bin/sh
sed -f wnn2skk.sed $@ | gawk -f wnn2skk.awk -
