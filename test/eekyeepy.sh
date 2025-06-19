#!/bin/bash

last_workflow_run=$(gh run list -R matvj250/test_repo_2_for_cloning --workflow date_test.yml --status success --limit 1 --json startedAt --jq '.[] | .startedAt')
current_workflow_run=$(gh run list -R matvj250/test_repo_2_for_cloning --workflow date_test.yml --status in_progress --limit 1 --json startedAt --jq '.[] | .startedAt')

echo "$last_workflow_run"
echo "$current_workflow_run"
gh run list -R matvj250/test_repo_2_for_cloning --workflow date_test.yml --limit 5 --json startedAt,status #--jq '.[] | .startedAt'

commitcount=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$last_workflow_run\") | select(.commit.committer.date <= \"$current_workflow_run\")" | wc -l)
echo "$commitcount"

# need # of commits + 1 to get the "old commit" for the earliest new commit
#git clone --branch master --depth $((commitcount+1)) https://github.com/apache/pinot.git
#cd pinot || exit
#log="$(git log --pretty=format:"%H" | tr "\n" " ")"
#IFS=' ' read -r -a hashlist <<< "$log"
#cd ..
#
#arrlen=${#hashlist[@]}
#for i in $( seq 1 "$((arrlen - 1))" ); do
#  if [[ i -eq 1 ]]; then
#      cd pinot || exit
#      echo "${hashlist[$((i-1))]}"
#      git checkout "${hashlist[$((i-1))]}"
#      mvn clean install -DskipTests -q -pl pinot-spi
#      echo "mvn clean #""$((i-1))"" done"
#      cd ..
#  fi
#  cd pinot || exit
#  echo "${hashlist[$i]}"
#  git checkout "${hashlist[$i]}"
#  mvn clean install -DskipTests -q -pl pinot-spi
#  echo "mvn clean #""$i"" done"
#  cd ..
#done


#commits=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$1\") | select(.commit.committer.date <= \"$2\") | .sha" | tr "\n" " ")
#IFS=' ' read -r -a hashlist <<< "$commits"
#echo "${hashlist[@]}"
#commitcount="${#hashlist[@]}"
## check out entire repo
##git clone --branch master --depth 10 https://github.com/apache/pinot.git
#cd pinot || exit
#baseline=$(git log --pretty=format:"%H" -1 "${hashlist[$((commitcount-1))]}"^)
##echo "$baseline"
#hashlist+=("$baseline")
#cd ..
#echo "commits being processed:" "${hashlist[*]}"

#commits=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"2025-06-16T23:00:00Z\") | select(.commit.committer.date <= \"2025-06-17T00:00:00Z\") | .sha")
#IFS=' ' read -r -a hashlist <<< "$commits"
#commitcount="${#hashlist[@]}"
#if [[ commitcount -eq 0 ]]; then
#  echo "There have been no commits in the past 30 minutes."
#  exit 0
#fi
#
## check out entire repo
#cd pinot || exit
#baseline=$(git log --pretty=format:"%H" -1 "${hashlist[$commitcount-1]}"^)
#echo "$baseline"
#hashlist+=("$baseline")
#cd ..
#
#echo ${#hashlist[@]}

#gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$1\")" | wc -l

#latest_pr=16066
#metadata=$(gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]')
#  node parse_japicmp.js \
#    --input data/japicmp/pr-"$latest_pr".txt \
#    --metadata "$metadata" \
#    --output data/output/pr-"$latest_pr".json

#echo $1
##current_datetime_minus_30m=$(date -u -v-4H +"%Y-%m-%dT%H:%M:%SZ")
## do a shallow clone. if there are no commits, exit the script
##commitcount=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$1\")" | wc -l)
##
##if [[ commitcount -eq 0 ]]; then
##  echo "There have been no commits in the past 30 minutes."
##  exit 0
##fi
##git clone --branch master --depth $((commitcount+1)) https://github.com/apache/pinot.git
#cd pinot || exit
#version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
#log="$(git log --pretty=format:"%H" | tr "\n" " ")"
#IFS=' ' read -r -a hashlist <<< "$log"
#
#echo "${#hashlist[@]}"
#echo "${hashlist[3]}"
#echo "${hashlist[4]}"
#
## make temp directories, download japicmp, and set boolean
#cd ..
#
#for i in $( seq 1 "${#hashlist[@]}" ); do
#  # we're only running mvn clean install twice for a PR at the beginning
#  # since afterwards, we'll always have one of the two sets of jars downloaded already
#  if [[ i -eq 1 ]]; then
#    echo "$i"
#    echo "${hashlist[i-1]}"
#  fi
#  echo "$i"
#  echo "${hashlist[i]}"
#done

#rm -rf pinot

#for i in $( seq 0 3 ); do
#  # we're only running mvn clean install twice for a PR at the beginning
#  # since afterwards, we'll always have one of the two sets of jars downloaded already
#  if [[ i -eq 0 ]]; then
#    echo "hi there $i"
#  fi
#  echo "hello there $i"
#done

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
