#!/bin/bash

help()
{
    echo "Removes lines that matches 'PATTERN' from files. By default works recursevily"
    echo ""
    echo "   usage: line-remove pattern"
}

# Exit if number of arguments is incorrect
[ ! $# == 1 ] && help && exit 0

pattern="$1"

files=$(grep -r "$pattern" . | cut -d : -f 1 | sort -u)

# Exit if no matches
[ "$files" == "" ] && echo "Nothing matches to: $pattern" && exit 0

numbeOfMatch=$(grep -r "$pattern" . | cut -d : -f 1 | sort -u | wc -l)

# Ask for confirmation
read -p "$numbeOfMatch file(s) matches. Do you wish to continue? (y/n)" answer
case $answer in
    [Yy]* ) break;;
    * ) echo "Aborting" && exit 0;;
esac

# Step-by-step remove matched lines with 'sed'
while read -r file
do
    echo "Modified file: $file"
    sed -i "/$pattern/d" "$file"
done <<< $(echo "$files")
