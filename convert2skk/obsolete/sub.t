#!PERLPATH
#
#	sub - ファイルの差をとる
#
#		1990	12/17	増井俊之
#
eval "exec PERLPATH -S $0 $*"
	if $Shell_cannot_understand;

if($#ARGV != 1){
	print stderr "sub file1 file2\n";
	print stderr " -- print lines included in file2 but not in file1\n";
	exit 0;
}
$filename1 = $ARGV[0];
$filename2 = $ARGV[1];
open(file1,$filename1) || die "Can't open file $filename1";
open(file2,$filename2) || die "Can't open file $filename2";
$w1 = <file1>;
$w2 = <file2>;
while(1){
	last if $w2 eq '' || $w1 eq '';
	if($w1 eq $w2){
		$w1 = <file1>;
		$w2 = <file2>;
	}
	elsif($w1 lt $w2){
		while($w1 lt $w2){
			$w1 = <file1>;
			last if $w1 eq '';
		}
		if($w1 gt $w2){
			print $w2;
			$w2 = <file2>;
		}
	}
	else{
		while($w1 gt $w2){
			print $w2;
			$w2 = <file2>;
			last if $w2 eq '';
		}
	}
}
if($w1 eq '' && $w2 ne ''){
	print $w2;
	while(<file2>){
		print;
	}
}
