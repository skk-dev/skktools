#!PERLPATH
while(<>){
	s/^\200\200//;
	print;
}
