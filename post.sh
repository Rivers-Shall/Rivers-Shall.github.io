#!/bin/bash
RESET="\033[0m"
BOLD_BLUE="\033[1;34m"

date=$(date "+%Y-%m-%d")
postPattern="source/_posts/${date}-"
# escape postPattern for sed
postPattern=$(echo ${postPattern} | sed -e 's/[]\/$*.^[]/\\&/g')
echo -e ${BOLD_BLUE}postPattern: ${postPattern}${RESET}

postName=$(git status | grep ${postPattern} | sed -n "/${postPattern}/s/${postPattern}//p")

echo -e ${BOLD_BLUE}postName: ${postName}${RESET}

postName=${postName%".md"}

echo -e ${BOLD_BLUE}postName: ${postName}${RESET}

echo "hexo g && hexo d && hexo clean && git add -A && git commit -m "post: ${postName}""

hexo g && hexo d && hexo clean && git add -A && git commit -m "post: ${postName}"