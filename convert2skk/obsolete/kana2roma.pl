#
#	平仮名文字列をローマ字文字列に変換する。
#
#	使用法: $romastr = &kana2roma($kanastr)
#
package kana2roma;

$cnv4{"きぃ"} = "kyi";
$cnv4{"きぇ"} = "kye";
$cnv4{"きゃ"} = "kya";
$cnv4{"きゅ"} = "kyu";
$cnv4{"きょ"} = "kyo";
$cnv4{"ぎぃ"} = "gyi";
$cnv4{"ぎぇ"} = "gye";
$cnv4{"ぎゃ"} = "gya";
$cnv4{"ぎゅ"} = "gyu";
$cnv4{"ぎょ"} = "gyo";
$cnv4{"しぃ"} = "syi";
$cnv4{"しぇ"} = "she";
$cnv4{"しゃ"} = "sha";
$cnv4{"しゅ"} = "shu";
$cnv4{"しょ"} = "sho";
$cnv4{"じぃ"} = "zyi";
$cnv4{"じぇ"} = "je";
$cnv4{"じゃ"} = "ja";
$cnv4{"じゅ"} = "ju";
$cnv4{"じょ"} = "jo";
$cnv4{"ちぃ"} = "tyi";
$cnv4{"ちぇ"} = "che";
$cnv4{"ちゃ"} = "cha";
$cnv4{"ちゅ"} = "chu";
$cnv4{"ちょ"} = "cho";
$cnv4{"ぢぃ"} = "dyi";
$cnv4{"ぢぇ"} = "dye";
$cnv4{"ぢゃ"} = "dya";
$cnv4{"ぢゅ"} = "dyu";
$cnv4{"ぢょ"} = "dyo";
$cnv4{"にぃ"} = "nyi";
$cnv4{"にぇ"} = "nye";
$cnv4{"にゃ"} = "nya";
$cnv4{"にゅ"} = "nyu";
$cnv4{"にょ"} = "nyo";
$cnv4{"ひぃ"} = "hyi";
$cnv4{"ひぇ"} = "hye";
$cnv4{"ひゃ"} = "hya";
$cnv4{"ひゅ"} = "hyu";
$cnv4{"ひょ"} = "hyo";
$cnv4{"びぃ"} = "byi";
$cnv4{"びぇ"} = "bye";
$cnv4{"びゃ"} = "bya";
$cnv4{"びゅ"} = "byu";
$cnv4{"びょ"} = "byo";
$cnv4{"ぴぃ"} = "pyi";
$cnv4{"ぴぇ"} = "pye";
$cnv4{"ぴゃ"} = "pya";
$cnv4{"ぴゅ"} = "pyu";
$cnv4{"ぴょ"} = "pyo";
$cnv4{"ふぁ"} = "fa";
$cnv4{"ふぃ"} = "fi";
$cnv4{"ふぇ"} = "fe";
$cnv4{"ふぉ"} = "fo";
$cnv4{"みぃ"} = "myi";
$cnv4{"みぇ"} = "mye";
$cnv4{"みゃ"} = "mya";
$cnv4{"みゅ"} = "myu";
$cnv4{"みょ"} = "myo";
$cnv4{"りぃ"} = "ryi";
$cnv4{"りぇ"} = "rye";
$cnv4{"りゃ"} = "rya";
$cnv4{"りゅ"} = "ryu";
$cnv4{"りょ"} = "ryo";

$cnv2{"ー"} = "-";
$cnv2{"ぁ"} = "xa";
$cnv2{"あ"} = "a";
$cnv2{"ぃ"} = "xi";
$cnv2{"い"} = "i";
$cnv2{"ぅ"} = "xu";
$cnv2{"う"} = "u";
$cnv2{"ぇ"} = "xe";
$cnv2{"え"} = "e";
$cnv2{"ぉ"} = "xo";
$cnv2{"お"} = "o";
$cnv2{"か"} = "ka";
$cnv2{"が"} = "ga";
$cnv2{"き"} = "ki";
$cnv2{"ぎ"} = "gi";
$cnv2{"く"} = "ku";
$cnv2{"ぐ"} = "gu";
$cnv2{"け"} = "ke";
$cnv2{"げ"} = "ge";
$cnv2{"こ"} = "ko";
$cnv2{"ご"} = "go";
$cnv2{"さ"} = "sa";
$cnv2{"ざ"} = "za";
$cnv2{"し"} = "shi";
$cnv2{"じ"} = "ji";
$cnv2{"す"} = "su";
$cnv2{"ず"} = "zu";
$cnv2{"せ"} = "se";
$cnv2{"ぜ"} = "ze";
$cnv2{"そ"} = "so";
$cnv2{"ぞ"} = "zo";
$cnv2{"た"} = "ta";
$cnv2{"だ"} = "da";
$cnv2{"ち"} = "chi";
$cnv2{"ぢ"} = "di";
$cnv2{"つ"} = "tsu";
$cnv2{"づ"} = "du";
$cnv2{"て"} = "te";
$cnv2{"で"} = "de";
$cnv2{"と"} = "to";
$cnv2{"ど"} = "do";
$cnv2{"な"} = "na";
$cnv2{"に"} = "ni";
$cnv2{"ぬ"} = "nu";
$cnv2{"ね"} = "ne";
$cnv2{"の"} = "no";
$cnv2{"は"} = "ha";
$cnv2{"ば"} = "ba";
$cnv2{"ぱ"} = "pa";
$cnv2{"ひ"} = "hi";
$cnv2{"び"} = "bi";
$cnv2{"ぴ"} = "pi";
$cnv2{"ふ"} = "fu";
$cnv2{"ぶ"} = "bu";
$cnv2{"ぷ"} = "pu";
$cnv2{"へ"} = "he";
$cnv2{"べ"} = "be";
$cnv2{"ぺ"} = "pe";
$cnv2{"ほ"} = "ho";
$cnv2{"ぼ"} = "bo";
$cnv2{"ぽ"} = "po";
$cnv2{"ま"} = "ma";
$cnv2{"み"} = "mi";
$cnv2{"む"} = "mu";
$cnv2{"め"} = "me";
$cnv2{"も"} = "mo";
$cnv2{"ゃ"} = "xya";
$cnv2{"や"} = "ya";
$cnv2{"ゅ"} = "xyu";
$cnv2{"ゆ"} = "yu";
$cnv2{"ょ"} = "xyo";
$cnv2{"よ"} = "yo";
$cnv2{"ら"} = "ra";
$cnv2{"り"} = "ri";
$cnv2{"る"} = "ru";
$cnv2{"れ"} = "re";
$cnv2{"ろ"} = "ro";
$cnv2{"わ"} = "wa";
$cnv2{"ゐ"} = "wi";
$cnv2{"ゑ"} = "we";
$cnv2{"を"} = "wo";
$cnv2{"ん"} = "n";

sub main'kana2roma {
	local($_) = @_;
	local($p, $s) = (0, "");
	while($p < length($_)){
		if($cnv4{substr($_,$p,4)}){
			if($tf){
				$s .= substr($cnv4{substr($_,$p,4)},0,1);
				$tf = 0;
			}
			$s .= $cnv4{substr($_,$p,4)};
			$p += 4;
		}
		elsif($cnv2{substr($_,$p,2)}){
			if($tf){
				$s .= substr($cnv2{substr($_,$p,2)},0,1);
				$tf = 0;
			}
			$s .= $cnv2{substr($_,$p,2)};
			$p += 2;
		}
		elsif(substr($_,$p,2) eq "っ"){
			$tf = 1;
			$p += 2;
		}
		elsif(ord(substr($_,$p)) >= 0x80){
			$s .= substr($_,$p,2);
			$p += 2;
		}
		else {
			$s .= substr($_,$p,1);
			$p += 1;
		}
	}
	return $s;
}

1;
