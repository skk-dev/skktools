#!/usr/local/bin/jperl -Pw

# ATOK7/ATOK8/松茸 V3/DFJのユーザ辞書(テキスト)を
# SKKの辞書に変換する
# written by nmaeda (Aug/1994)

$backup="";
$line="";

while(<>)	{
	chop;

	if(/[!-ﾟ]/)	{	# half-width kana to full-width
		s/\([ｦ-ﾟ]\)ー/\1ｰ/g;
		tr/ｧｱｨｲｩｳｪｴｫｵｶｷｸｹｺｻｼｽｾｿﾀﾁｯﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓｬﾔｭﾕｮﾖﾗﾘﾙﾚﾛﾜｦﾝﾞﾟ/ァアィイゥウェエォオカキクケコサシスセソタチッツテトナニヌネノハヒフヘホマミムメモャヤュユョヨラリルレロワヲン゛゜/;
		tr/｡､｢｣ｰ/。、「」ー/;

		s/カ゛/ガ/g; s/キ゛/ギ/g; s/ク゛/グ/g; s/ケ゛/ゲ/g; s/コ゛/ゴ/g;
		s/サ゛/ザ/g; s/シ゛/ジ/g; s/ス゛/ズ/g; s/セ゛/ゼ/g; s/ソ゛/ゾ/g;
		s/タ゛/ダ/g; s/チ゛/ヂ/g; s/ツ゛/ヅ/g; s/テ゛/デ/g; s/ト゛/ド/g;
		s/ハ゛/バ/g; s/ヒ゛/ビ/g; s/フ゛/ブ/g; s/ヘ゛/ベ/g; s/ホ゛/ボ/g;
		s/ハ゜/パ/g; s/ヒ゜/ピ/g; s/フ゜/プ/g; s/ヘ゜/ペ/g; s/ホ゜/ポ/g;
		s/ウ゛/ヴ/g;

	}

	@array=split(/,/);
	$array[0]=~tr/ァ-ン/ぁ-ん/;
	$array[1]=~s/"//g;

	if($backup!~/^$array[0]$/)	{	# New entry
		if($line!~/^$/)	{
			printf("%s\n", $line);
		}
		$line=sprintf("%s /%s/", $array[0], $array[1]);
	} else	{				# continue
		$line=$line.$array[1]."/";
	}
	$backup=$array[0];
}
printf("%s\n", $line);


