#
#	漢字コード変換
#
package codeconv;

sub main'jis2sjis {
	local($_) = @_;
	return &conv($_, "jis2sjis");
}

sub main'sjis2jis {
	local($_) = @_;
	return &conv($_, "sjis2jis");
}

sub main'jis2ujis {
	local($_) = @_;
	return &conv($_, "jis2ujis");
}

sub main'ujis2jis {
	local($_) = @_;
	return &conv($_, "ujis2jis");
}

sub conv {
	local($_, $func) = @_;
	local($s) = "";
	local($jtox) = ($func =~ /^j/);
	while(! /^$/){
		if(s/^[^\033\200-\377]+//){
			$s .= $&;
		}
		elsif(s/^([\200-\377].)+//){
			$s .=  ($jtox ? $& : do $func($&)) ;
		}
		elsif(s/^\033\$.(([^\033].)*)\033\(.//){
			$s .= ($jtox ? do $func($1) : $&) ;
		}
		else {
			s/.// ;
		}
	}
	return $s;
}

sub sjis2jis {
	local($result) = '';
	local($_) = @_;
	local($c1, $c2);
	while(s/^(.)(.)//){
		$c1 = (ord($1) + 0x100) & 0xff;
		$c2 = (ord($2) + 0x100) & 0xff;
		$c1 -= 0x40 if $c1 >= 0xe0;
		$c2-- if $c2 >= 0x80;
		$j1 = ($c1-0x81) * 2 + ($c2>=0x9e ? 1 : 0) + 0x21;
		$j2 = ($c2 >= 0x9e ? $c2-0x9e : $c2-0x40) + 0x21;
		$result .= sprintf("%c%c",$j1,$j2);
	}
	"\033\$B" . $result . "\033(B" ;
}

sub jis2sjis {
	local($result) = '';
	local($_) = @_;
	local($c1, $c2, $j1, $j2);
	while(s/^(.)(.)//){
		$c1 = (ord($1) - 0x21) / 2 + 0x81;
		$c2 = (ord($1) & 1 ? ord($2) - 0x21 + 0x40 : ord($2) - 0x21 + 0x9e);
		$j1 = ($c1 >= 0xa0 ? $c1 + 0x40 : $c1);
		$j2 = ($c2 >= 0x7f ? $c2 + 1 : $c2);
		$result .= sprintf("%c%c",$j1,$j2);
	}
	$result ;
}

sub ujis2jis {
	local($result) = '';
	local($_) = @_;
	while(s/^(.)(.)//){
		$result .= sprintf("%c%c",ord($1) & 0x7f,ord($2) & 0x7f);
	}
	"\033\$B" . $result . "\033(B" ;
}

sub jis2ujis {
	local($result) = '';
	local($_) = @_;
	while(s/^(.)(.)//){
		$result .= sprintf("%c%c",ord($1) | 0x80,ord($2) | 0x80);
	}
	$result ;
}

1;
