BEGIN{
    FS=" +";
    print(";; okuri-nasi entries.");
}
!/^\\/{
    printf("%s /%s/\n", $1, $2);
}
