#!/bin/bash
cd $(dirname $0)
. ./creds.env
if [ "$(pgrep node)" != "" ]
then
    echo "Killing previous process... ($(pgrep node))"
    pkill node
fi
echo 'starting nina-bot'
nohup bin/hubot -n nina-bot -a xmpp >> /var/log/hubot.log 2>&1 &
