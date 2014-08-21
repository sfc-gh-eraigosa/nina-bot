#!/bin/bash
CACHE_FILE=/tmp/serverdate.lst
COST=100
echo "Querying kits ages..."
hpcloud servers -d , -a $1 -c name,public_ip,created > $CACHE_FILE
#hpcloud servers -a $1 | awk '{ FS = "|" ; print $3","$6","$10 }' > $CACHE_FILE
for kit in $(cat $CACHE_FILE | grep -E ".*(maestro|eroplus)" | sed -E "s/maestro\.|-eroplus//g" | sed "s/ [0-9]* *, /,/g")
do
    id=$(echo $kit | awk -F, '{ print $1 }')
    date=$(echo $kit | awk -F, '{ print $3 }')
    date=$(date --date="$date" +%s) #transforms date text to date
    now=$(date +%s)
    diff=$(( ($now - $date) / 86400 ))
    if (( $diff > 1 )); then
       plural="s"
    else
       plural=""
    fi
    #COSTS
    cost=$(echo "scale=2;$COST / 30 * $diff" | bc)
    echo "$id -> $diff day$plural old, kit cost \$$cost"
done
echo "(Cost estimated by a monthly fee of \$$COST)"
