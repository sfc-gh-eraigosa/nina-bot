#!/bin/bash
if [ "$(pgrep node)" != "" ]
then
  echo "Killing previous process... ($(pgrep node))"
  pkill node
fi
cd $(dirname $0)
[ -f ./creds.env ] && . ./creds.env
[ -f ./admins.env ] && . ./admins.env
[ -f ./requirements.env ] && . ./requirements.env
echo 'starting nina-bot'
nohup bin/hubot -n nina-bot -a xmpp >> /var/log/hubot.log 2>&1 &
