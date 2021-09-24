#!/bin/sh

date=20210924
release_number=21
release_variation=1

branch="qa-r${release_number}"
release_name="release/qa-r${release_number}.${release_variation}-${date}"
tagname="TAG_QA-R${release_number}.${release_variation}-${date}"

echo "hello"

base_branch="preprod-r${release_number}"
array=($(awk -F= '{print $1}' repo.list))
rm -rf gitrepos
mkdir -p gitrepos && cd gitrepos

for element in ${array[@]}
do
  echo "clonning $element"
  git clone $element
  basename=$(basename $element)
  foldername=${basename%.*}
  cd $foldername
  git checkout $branch
  git pull
  git checkout -b $release_name
  git push -u origin $release_name
  gh pr create -H $release_name -B $base_branch -t "Merging $release_name into $base_branch" -b "Merging $release_name into $base_branch"
  gh pr merge -m -b "Merged $release_name with $base_branch"
  echo "***************************************************"
  echo "Tagging"
  git pull
  git tag $tagname
  git push -u origin $tagname
  cd ..
done
git checkout main
