#!/bin/bash
if [ "$(pgrep node)" != "" ]
then
  echo "Killing previous process... ($(pgrep node))"
  pkill node
fi

cd $(dirname $0)
[ -f ./admins.env ] && . ./admins.env
echo 'starting nina-bot'
bin/hubot -n nina-bot -a shell
