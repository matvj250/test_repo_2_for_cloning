#!/bin/bash

if [ -d commit_jars_old ]; then
  rm -r commit_jars_old
fi
if [ -d commit_jars_new ]; then
  rm -r commit_jars_new
fi
mkdir commit_jars_old
mkdir commit_jars_new

git remote add remote_apache_pinot https://github.com/apache/pinot.git
gh repo set-default remote_apache_pinot
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
# below is seemingly the best way to get commits via github CLI
commits="$(gh search commits repo:apache/pinot --committer-date=">1970-01-01" --sort committer-date --order desc --limit 2 --json sha)"
latest="$(echo "$commits" | jq '.[0].sha' | tr -d '"')" # latest commit hash
sndlatest="$(echo "$commits" | jq '.[1].sha' | tr -d '"')"
latest_pr="$(gh api repos/apache/pinot/commits/"${latest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')" # corresponding PR number
echo "$latest_pr"
sndlatest_pr="$(gh api repos/apache/pinot/commits/"${sndlatest}"/pulls \
  -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')"

git fetch remote_apache_pinot "$latest"
git checkout "$latest"
mvn clean install -DskipTests
paths="$(find . -type f -name "*${version}.jar" | tr "\n" " ")"
echo "$paths"
#IFS=' ' read -r -a namelist <<< "$paths"
#for name in "${namelist[@]}"; do
#  mv "$name" commit_jars_new
#done
#
#git fetch remote_apache_pinot "$sndlatest"
#git checkout "$sndlatest"
#mvn clean install -DskipTests
#paths2="$(find . -path ./commit_jars_new -prune -o -name "*${version}.jar" -type f -print | tr "\n" " ")"
#IFS=' ' read -r -a namelist2 <<< "$paths2"
#for name in "${namelist2[@]}"; do
#  mv "$name" commit_jars_old
#done

gh repo set-default matvj250/test_repo
git checkout main
git remote remove remote_apache_pinot

#if [ ! -e japicmp.jar ]; then
#  JAPICMP_VER=0.23.1
#  curl -fSL \
#  -o japicmp.jar \
#  "https://repo1.maven.org/maven2/com/github/siom79/japicmp/japicmp/${JAPICMP_VER}/japicmp-${JAPICMP_VER}-jar-with-dependencies.jar"
#  if [ ! -f japicmp.jar ]; then
#    echo "Error: Failed to download japicmp.jar."
#    exit 1
#  fi
#fi
#
#if [ ! -e japicmp_test_commit.txt ]; then
#  touch japicmp_test_commit.txt
#fi
#message="Comparing #${latest_pr} (https://github.com/apache/pinot/pull/${latest_pr})
#        against the last-merged PR #${sndlatest_pr} (https://github.com/apache/pinot/pull/${sndlatest_pr})"
#echo "$message" > japicmp_test_commit.txt
#for filename in commit_jars_new/*; do
#  name="$(basename "$filename")"
#  if [ ! -f commit_jars_old/"$name" ]; then
#    echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> japicmp_test.txt
#    echo "" >> japicmp_test_commit.txt
#    continue
#  fi
#  OLD=commit_jars_old/"$name"
#  NEW=commit_jars_new/"$name"
#  java -jar japicmp.jar \
#    --old "$OLD" \
#    --new "$NEW" \
#    -a private \
#    --no-annotations \
#    --ignore-missing-classes \
#    --only-modified >> japicmp_test_commit.txt
#done