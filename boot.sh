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
        username=$(echo "$github" | tr '[:upper:]' '[:lower:]')
        adduser --gecos "" --disabled-password $username
        echo "$username:$email" | chpasswd
        cp hello-ruby.ipynb /home/$username/hello-ruby.ipynb
        chown $username:$username /home/$username/hello-ruby.ipynb
        echo "$email (@$github) created."
    fi

done
