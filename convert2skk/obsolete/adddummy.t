#!PERLPATH
while(<>){
	if(/^[\001-\177]/){
		$_ = "\200\200" . $_;
	}
	print;
}
