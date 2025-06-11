#!/bin/bash

#TODO: github token and imports
# make temp directories
mkdir commit_jars_old
mkdir commit_jars_new

# clone only the last 2 commits of apache/pinot, since that's all we care about
mkdir pinot
cd pinot || exit
git init
git remote add origin https://github.com/apache/pinot.git
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
latest=7c3c8e87052edca26648a646850b2b17ec0aa690
# "${hashlist[0]}" # latest commit hash
sndlatest=3ffa7c3e3237277c6a60fb3379d0a5c44e8240e0
#"${hashlist[1]}"
latest_pr="$(gh api repos/apache/pinot/commits/"${latest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')" # corresponding PR number

git fetch origin "$latest"
git checkout "$latest"
mvn clean install -DskipTests
paths="$(find . -type f -name "*${version}.jar" -print | tr "\n" " ")" # get all module jars made by mvn clean install
IFS=' ' read -r -a namelist <<< "$paths"
cd ..
for name in "${namelist[@]}"; do
  mv "pinot/$name" commit_jars_new # move them into folder in the base repo
done

cd pinot || exit
git fetch origin "$sndlatest"
git checkout "$sndlatest"
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
if [ ! -e japicmp_"$latest_pr".txt ]; then
  touch japicmp_"$latest_pr".txt
fi
for filename in commit_jars_new/*; do
  name="$(basename "$filename")"
  if [ ! -f commit_jars_old/"$name" ]; then
    echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> japicmp_"$latest_pr".txt
    echo "" >> japicmp_"$latest_pr".txt
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
    --only-modified >> japicmp_"$latest_pr".txt
done

# "unclone" pinot
cd pinot || exit
rm -rf .git
cd ..
rm -r pinot

# remove temp directories
#rm -r commit_jars_old
#rm -r commit_jars_new

# create json
metadata=$(gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]')
node parse_japicmp.js \
  --input japicmp_"$latest_pr".txt \
  --metadata "$metadata" \
  --output japicmp_"$latest_pr".json