#
BEGIN{
    FS="[\t ]+";
    #print(";; okuri-nasi entries.");
    annotation = ""
}
($0 !~ /^\\/) && ($0 !~ /\/.*:$/) && ($0 !~/^$/){
  if (match($0, "#") > 0) {
    annotation = substr($0, RSTART + 1);
  } else annotation = "";
  annotation = $3 annotation;
  if (annotation != "") {
    sub("^ ", "", annotation);
    printf("%s /%s;%s/\n", $1, $2, annotation);
  } else
    printf("%s /%s/\n", $1, $2);
}
