#!/bin/sh

INPUT="students.tsv"

if [ ! -f "$INPUT" ]; then
    echo "$INPUT file not found."
    exit 99
fi

cat $INPUT | \
    tr "\t" "," | \
    while IFS=, read lastname firstname email group github image1 image2 team1 team2 comment semaine
do
    if [ $email != "-" ] && [ $email != "Email" ];
    then
        adduser --gecos "" --disabled-password --force-badname $github
        echo "$github:$email" | chpasswd
        cp hello-ruby.ipynb /home/$github/hello-ruby.ipynb
        chown $github:$github /home/$github/hello-ruby.ipynb
        echo "$email (@$github) created."
    fi

done
