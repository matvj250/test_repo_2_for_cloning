#!/bin/bash

for i in $( seq 0 3 ); do
  # we're only running mvn clean install twice for a PR at the beginning
  # since afterwards, we'll always have one of the two sets of jars downloaded already
  if [[ i -eq 0 ]]; then
    echo "hi there $i"
  fi
  echo "hello there $i"
done

#current_datetime_minus_30m=$(date -u -v-3H +"%Y-%m-%dT%H:%M:%SZ")
#commitcount=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$current_datetime_minus_30m\")" | wc -l)
#echo $((commitcount + 5))

#current_datetime=$(date '+%Y-%m-%d %H:%M:%S') #-d "-30 minutes"
#time2=$(date -j -v-30M -f '%Y-%m-%d %H:%M:%S' "$current_datetime" '+%Y-%m-%d %H:%M:%S')
#echo $time2
#git clone --branch master --shallow-since="$time2" https://github.com/apache/pinot.git || { echo "Error: Failed to clone repository. It's most likely that there have just been no commits in the past 30 minutes."; exit 1; }
#cd pinot || exit
#git log --pretty=format:"%H"
#rm -rf .git
#cd ..
#rm -r pinot

# commit_count="$(gh search commits repo:apache/pinot --committer-date=">${stime}" --sort committer-date --order desc --limit 50 --json sha --jq length)"
#touch ../commit_jars_new/test.txt

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
