#!/bin/bash
hpcloud_cdk.sh --a $1 >/dev/null
CACHE_FILE=/tmp/hpcloud_cdk.sh.lst
for PREFIX in $(sed 's/ [0-9]*,/,/g' $CACHE_FILE | awk -F, '$1 ~ /-(ci|review|util|eroplus)$/ || $1 ~ /^(eroplus|maestro|ci|review|util)\./ { printf "%s\n",$1}' | sed 's/\(-[a-z]*\|[a-z]*\.\)//g' | sort -u )
 do
   RESULT="$RESULT$PREFIX "
 done
echo "Existing kits:$RESULT"

kits=""
noreg=""
array=($RESULT)
for item in ${array[@]}
do
  curl $2/search/instance_id/$item -s | grep result\":\\[\\], >/dev/null
  if [ $? -ne 0 ]; then
     kits="$kits $item"
  else
     noreg="$noreg $item"
  fi
done
echo "Registered kits:$kits"
echo "Not Registered:$noreg"