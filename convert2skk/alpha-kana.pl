#!/usr/local/bin/jperl -Pw

# SKKの辞書から、
#   見出しがアルファベットで、表記がカタカナ、
# であるエントリを探し、
#   見出しがカタカナで、表記もカタカナ、
# に変換し、表示する。
#
# written by nmaeda@SANSEIDO Printing Co.,Ltd. (Aug/1994)

open(handle, "| sort | uniq") || die "can't open pipe\n";

while(<>)	{
	chop;

	# 表記がカタカナ(漢字との複合語ではない)
	if(/^([a-zA-Z]+) .*\/([ァ-ヶ][ァ-ヶー・]+)\//)	{
		$alpha_read=$1;

		$count=0;
		while($_=~/\/([ァ-ヶ][ァ-ヶー・]+)\//)	{
			$face=$1;
			$kana_read=$face;
			$kana_read=~s/・//g;	# 読みから'・'を削除
			$kana_read=~tr/ァ-ン/ぁ-ん/;	# 読みをひらがなに
			if($kana_read=~/[ァ-ヶ]/)	{
				$_=$';
				next;	# ヴ-ヶをふくむエントリは削除
			}
			printf(handle "%s /%s/\n", $kana_read, $face);
			$_=$';
			$count++;
		}
		printf(STDERR "%d %-50s\r", $count, $alpha_read);
	}	
}

close(handle);
