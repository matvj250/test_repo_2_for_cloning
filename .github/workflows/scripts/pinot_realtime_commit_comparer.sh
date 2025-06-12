#!/bin/bash

# get count of commits from last 30 minutes
current_datetime=$(date '+%Y-%m-%d %H:%M:%S') #-d "-30 minutes"
stime=$(date -j -v-2H -f '%Y-%m-%d %H:%M:%S' "$current_datetime" '+%Y-%m-%d %H:%M:%S')
# do a shallow clone. if there are no commits, exit the script
git clone --branch master --shallow-since="$stime" https://github.com/apache/pinot.git || \
 { echo "Error: Failed to clone repository. It's most likely that there have just been no commits in the past 30 minutes."; exit 1; }
cd pinot || exit
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
log="$(git log --pretty=format:"%H" | tr "\n" " ")"
IFS=' ' read -r -a hashlist <<< "$log"

# make temp directories, download japicmp, and set boolean
cd ..
mkdir commit_jars_old
mkdir commit_jars_new
if [ ! -e japicmp.jar ]; then
  JAPICMP_VER=0.23.1
  curl -fSL \
  -o japicmp.jar \
  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
  if [ ! -f japicmp.jar ]; then
    echo "Error: Failed to download japicmp.jar."
    exit 1
  fi
fi
firstpair=true

for i in $( seq 0 "${#hashlist[@]}" ); do
  # we're only running mvn clean install twice for a PR at the beginning
  # since afterwards, we'll always have one of the two sets of jars downloaded already
  if [[ $firstpair ]]; then
    cd pinot || exit
    git checkout "${hashlist[i]}"
    mvn clean install -DskipTests
    paths="$(find . -type f -name "*${version}.jar" -print | tr "\n" " ")" # get all module jars made by mvn clean install
    IFS=' ' read -r -a namelist <<< "$paths"
    cd ..
    for name in "${namelist[@]}"; do
      mv "pinot/$name" commit_jars_new # move them into folder in the base repo
    done
    firstpair=false
  fi
  latest_pr="$(gh api repos/apache/pinot/commits/"${hashlist[i]}"/pulls \
        -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')" # corresponding PR number
  cd pinot || exit
  git checkout "${hashlist[i+1]}"
  mvn clean install -DskipTests
  paths2="$(find . -type f -name "*${version}.jar" -print | tr "\n" " ")"
  IFS=' ' read -r -a namelist2 <<< "$paths2"
  cd ..
  for name in "${namelist2[@]}"; do
    mv "pinot/$name" commit_jars_old
  done

  if [ -z "$( ls -A 'commit_jars_new' )" ]; then
      echo "The jars for the latest PR were not collected properly. Please investigate the cause of this."
      exit 1
  elif [ -z "$( ls -A 'commit_jars_old' )" ]; then
      echo "The jars for the second-latest PR were not collected properly. Please investigate the cause of this."
      exit 1
  fi

  # below block of code generates japicmp report
  touch data/japicmp/pr-"$latest_pr".txt
  for filename in commit_jars_new/*; do
    name="$(basename "$filename")"
    if [ ! -f commit_jars_old/"$name" ]; then
      echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> data/japicmp/pr-"$latest_pr".txt
      echo "" >> data/japicmp/pr-"$latest_pr".txt
      continue
    fi
    OLD=commit_jars_old/"$name"
    NEW=commit_jars_new/"$name"
    java -jar japicmp.jar \
      --old "$OLD" \
      --new "$NEW" \
      -a private \
      --no-annotations \
      --ignore-missing-classes \
      --only-modified >> data/japicmp/pr-"$latest_pr".txt
  done

  # create json
  metadata=$(gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]')
  node parse_japicmp.js \
    --input data/japicmp/pr-"$latest_pr".txt \
    --metadata "$metadata" \
    --output data/output/pr-"$latest_pr".json

  # move commit_jars_old to commit_jars_new
  # since the "old" PR is now being analyzed for changes
  rm -r commit_jars_new/*
  mv commit_jars_old/*  commit_jars_new
done

# "unclone" pinot
cd pinot || exit
rm -rf .git
cd ..
rm -r pinot

# remove temp directories
rm -r commit_jars_old
rm -r commit_jars_new