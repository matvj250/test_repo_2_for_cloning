#!/bin/bash

tenny="$(git log --pretty=format:"%H" | tr "\n" " ")"
IFS=' ' read -r -a hashlist <<< "$tenny"
latest="${hashlist[0]}" # latest commit hash
sndlatest="${hashlist[1]}"
echo "$latest"
echo "$sndlatest"
