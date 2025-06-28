#!/bin/sh

git_root="$(git rev-parse --show-toplevel)"
adr_directory="${git_root}/adr"
current_iso_date="$(date +"%Y-%m-%d")"

old_ifs="$IFS"
IFS="-"
name="$*"
IFS="$old_ifs"

if [ -z "$name" ]; then
    name="untitled"
fi

filename="${adr_directory}/${current_iso_date}_${name}.md"
touch "$filename"
echo "New ADR created: $filename"
