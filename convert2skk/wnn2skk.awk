# Known Bugs; $2 の後に SPC が入ってしまう (取り除けない)。
#
BEGIN{
    FS=" +";
    print(";; okuri-nasi entries.");
}
($0 !~ /^\\/) && ($0 !~ /\/\|単漢字:$/) && ($0 !~/^$/){
    #gsub(/ /,"", $2);
    printf("%s /%s/\n", $1, $2);
}
