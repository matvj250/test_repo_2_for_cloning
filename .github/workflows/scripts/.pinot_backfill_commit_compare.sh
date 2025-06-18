#!/bin/bash

# get commits between the two times provided. if there are no commits, exit the script
# note: I could do below with git log --before --after as well after cloning pinot
commits=$(gh api repos/apache/pinot/commits --jq ".[] | select(.commit.committer.date >= \"$1\") | select(.commit.committer.date <= \"$2\") | .sha")
IFS=' ' read -r -a hashlist <<< "$commits"
commitcount="${#hashlist[@]}"
if [[ commitcount -eq 0 ]]; then
  echo "There have been no commits in the past 30 minutes."
  exit 0
fi

# check out entire repo
git clone --branch master https://github.com/apache/pinot.git
cd pinot || exit
version="$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | tr -d "%")" # there's a % at the end for some reason
baseline=$(git log --pretty=format:"%H" -1 "${hashlist[$commitcount-1]}"^)
hashlist+=("$baseline")
cd ..
echo "commits being processed:" "${hashlist[*]}"

# get current repo and other steps
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"
git clone --branch main --depth 1 https://github-actions[bot]:"${GH_TOKEN}"@github.com/matvj250/test_repo_2_for_cloning.git temp_repo

# make temp directories, download japicmp, and set boolean
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

# length - 1 because the final entry of the array is just a space
arrlen=${#hashlist[@]}
prnames=()
for i in $( seq 1 "$((arrlen - 1))" ); do
  latest_pr="$(gh api repos/apache/pinot/commits/"${hashlist[i-1]}"/pulls \
          -H "Accept: application/vnd.github.groot-preview+json" | jq '.[0].number')" # corresponding PR number
  cd temp_repo || exit
  if [[ -e data/japicmp/pr-"$latest_pr".txt ]]; then
    echo "The change report for this PR already exists. The workflow will continue and just skip the process for this one."
    cd ..
    continue
  fi
  cd ..
  # we're only running mvn clean install twice for a PR at the beginning
  # since afterwards, we'll always have one of the two sets of jars downloaded already
  if [[ i -eq 1 ]]; then
    cd pinot || exit
    git checkout "${hashlist[i-1]}"
    mvn clean install -DskipTests -q -pl pinot-spi
    echo "mvn clean # ""$((i-1))"" done"
    paths="$(find . -type f -name "*${version}.jar" -print | tr "\n" " ")" # get all module jars made by mvn clean install
    IFS=' ' read -r -a namelist <<< "$paths"
    cd ..
    for name in "${namelist[@]}"; do
      mv "pinot/$name" commit_jars_new # move them into folder in the base repo
    done
  fi
  cd pinot || exit
  git checkout "${hashlist[i]}"
  mvn clean install -DskipTests -q -pl pinot-spi
  echo "mvn clean # ""$i"" done"
  paths2="$(find . -type f -name "*${version}.jar" -print | tr "\n" " ")"
  IFS=' ' read -r -a namelist2 <<< "$paths2"
  cd ..
  for name in "${namelist2[@]}"; do
    mv "pinot/$name" commit_jars_old
  done

  # fail process if either temp directory doesn't have files, meaning something went wrong
  if [ -z "$( ls -A 'commit_jars_new' )" ]; then
      echo "The jars for the latest PR were not collected properly. Please investigate the cause of this."
      exit 1
  elif [ -z "$( ls -A 'commit_jars_old' )" ]; then
      echo "The jars for the second-latest PR were not collected properly. Please investigate the cause of this."
      exit 1
  fi

  # below block of code generates japicmp report
  touch pr-"$latest_pr".txt
  for filename in commit_jars_new/*; do
    name="$(basename "$filename")"
    if [ ! -f commit_jars_old/"$name" ]; then
      echo "It seems $name does not exist in the previous pull request. Please make sure this is intended." >> pr-"$latest_pr".txt
      echo "" >> pr-"$latest_pr".txt
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
      --only-modified >> pr-"$latest_pr".txt
  done

  # create json
  metadata=$(gh pr view "$latest_pr" -R apache/pinot --json title,number,mergedAt,files,url -q '.files |= [.[] | .path]')
  node parse_japicmp.js \
    --input pr-"$latest_pr".txt \
    --metadata "$metadata" \
    --output pr-"$latest_pr".json

  prnames+=("$latest_pr")
  mv pr-"$latest_pr".txt temp_repo/data/japicmp
  mv pr-"$latest_pr".json temp_repo/data/output

  # move commit_jars_old to commit_jars_new
  # since the "old" PR is now being analyzed for changes
  rm -r commit_jars_new/*
  mv commit_jars_old/* commit_jars_new
done

echo "done with file generation"
# check here to avoid code running when everything created overlaps with preexisting files
# this should never be necessary, but it's good to be safe
if [[ ${#prnames[@]} -ne 0 ]]; then
  cd temp_repo || exit
  git add .
  git commit -m "Adding files for PRs ${prnames[*]}"
  git remote rm origin
  git remote add origin 'git@github.com:matvj250/test_repo_2_for_cloning.git'
  git push origin main || { echo "push failed"; exit 1; }
  cd ..
fi

# "unclone" repos
rm -rf pinot
rm -rf temp_repo

# remove temp directories
rm -rf commit_jars_old
rm -rf commit_jars_new
