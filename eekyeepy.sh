#!/bin/bash
latest_pr=15844
#15973

metadata=$(gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]')

node parse_japicmp.js \
  --input japicmp_"$latest_pr".txt \
  --metadata "$metadata" \
  --output japicmp_"$latest_pr"_revised.json

#mkdir pinot
#cd pinot
#git init
#git remote add origin https://github.com/apache/pinot.git
#git fetch origin fe7086b1bfd053585feeb9cfe0aeaa90936958d7
#git checkout FETCH_HEAD

#latest=fe7086b1bfd053585feeb9cfe0aeaa90936958d7
#latest_pr="$(gh api repos/apache/pinot/commits/"${latest}"/pulls \
#  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')"
#gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]' > japicmp_"$latest_pr".json

# if [ -z "$( ls -A 'commit_jars_new' )" ]; then
#     echo "Directory is empty"
# else
#     echo "Directory is not empty"
# fi

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
