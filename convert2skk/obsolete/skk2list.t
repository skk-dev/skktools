#!PERLPATH
while(<>){
	chop;
	if(/^([^ \t]+)[ \t]+([^ \t]+)$/){
		$_ = $2;
		$w = $1;
		s/\[([\200-\377][\200-\377])+\/([\200-\377][\200-\377])+\/\]\///g;
		while(s/^\/(([\200-\377].)+)//){
			$kanji = $1;
			print "$w $kanji\n" if $w ne &hiragana($kanji);
		}
	}
}
sub hiragana {
	local($result) = '';
	local($_) = @_;
	local($c1,$c2);
	while(s/^(.)(.)//){
		$c1 = ord($1); $c2 = ord($2);
		$c1 = 0xa4 if $c1 == 0xa5;
		$result .= sprintf("%c%c",$c1,$c2);
	}
	$result;
}

