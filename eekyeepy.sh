#!/bin/bash

 if [ -z "$( ls -A 'commit_jars_new' )" ]; then
     echo "Directory is empty"
 else
     echo "Directory is not empty"
 fi

#cd pinot || exit
#mkdir commit_jars_new
#mvn clean install -DskipTests -pl pinot-spi
#paths="$(find . -type f -name "*1.4.0-SNAPSHOT.jar" | tr "\n" " ")"
#IFS=' ' read -r -a namelist <<< "$paths"
#cd ..
#for name in "${namelist[@]}"; do
#  mv "pinot/$name" commit_jars_new
#done

#log="$(git log --pretty=format:"%H" | tr "\n" " ")"
#IFS=' ' read -r -a hashlist <<< "$log"
#echo "${hashlist[0]}"

#tenny="$(git log --pretty=format:"%H" | tr "\n" " ")"
#IFS=' ' read -r -a hashlist <<< "$tenny"
#latest="${hashlist[0]}" # latest commit hash
#sndlatest="${hashlist[1]}"
#echo "$latest"
#echo "$sndlatest"
