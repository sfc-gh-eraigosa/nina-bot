#!/bin/bash
if [ "$(id -u)" = "0" ] ;
then
  echo "WARNING: your running as root"
fi
BOT_DIR_NAME=$(dirname $0)
[[ -f "${BOT_DIR_NAME}/stop-bot.sh" ]] && bash "${BOT_DIR_NAME}/stop-bot.sh"

_CWD=$(pwd)
cd "${BOT_DIR_NAME}"
[ -f ./creds.env ] && . ./creds.env
[ -f ./admins.env ] && . ./admins.env
[ -f ./requirements.env ] && . ./requirements.env
echo 'starting nina-bot'
[ ! -d /var/log/hubot ] && mkdir -p /var/log/hubot
touch /var/log/hubot/nina-bot.log > /dev/null 2<&1
if [ $? -eq 0 ] ; then
  LOG_FILE=/var/log/hubot/nina-bot.log
else
  echo "WARNING: logging to ~/nina-bot.log, no write permission to /var/log/hubot"
  LOG_FILE=~/nina-bot.log
fi
nohup bin/hubot -n nina-bot -a xmpp >> "${LOG_FILE}" 2>&1 &
cd "${_CWD}"

if [ "$(pgrep node)" = "" ]; then
  echo "bin/hubot failed to start"
  tail -20 "${LOG_FILE}"
  echo "check the log : ${LOG_FILE}"
  exit 1
fi
