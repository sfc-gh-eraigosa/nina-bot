#!/bin/bash
if [ "$(id -u)" = "0" ] ;
  echo "WARNING: your running as root"
fi
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
[ ! -d /var/log/hubot ] && mkdir -p /var/log/hubot
nohup bin/hubot -n nina-bot -a xmpp >> /var/log/hubot/nina-bot.log 2>&1 &
