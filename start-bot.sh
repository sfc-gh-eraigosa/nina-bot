#!/bin/bash
cd $(dirname $0)
. ./creds.env
echo 'starting nina-bot'
nohup bin/hubot -n nina-bot -a xmpp >> /var/log/hubot.log 2>&1 &
