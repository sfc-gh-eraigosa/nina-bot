#!/bin/bash
#
# our goal is to connect to an ssh server
# as defined by the current git remote for origin
# and run start.sh
SSH_ALIAS=$(git remote -v|grep -e '^origin.*'|grep -e '(fetch)$'|awk '{print $2}'|awk -F: '{print $1}')
SSH_PATH=$(git remote -v|grep -e '^origin.*'|grep -e '(fetch)$'|awk '{print $2}'|awk -F: '{print $2}')
ssh -T $SSH_ALIAS exit > /dev/null 2<&1
if [ $? -eq 0 ] ; then
  echo "attempting to perform bot start"
  ssh $SSH_ALIAS bash -c "cd $SSH_PATH;git reset --hard"
  ssh $SSH_ALIAS bash -c $SSH_PATH/start-bot.sh
  if [ $? -eq 0 ] ; then
    echo "bot start success"
  else
    echo "bot failed to start"
    exit 1
  fi
else
  echo "unable to perform bot start"
fi

