Reference
----------------------
  https://github.com/github/hubot/blob/master/docs/README.md
  https://github.com/markstory/hubot-xmpp
  http://wiki.cdkdev.org/w/index.php/Hubot

NodeJS setup
----------------------
  mkdir -p /opt/config/production/git
  cd /opt/config/production/git
  sudo -i
  apt-get -y update
  apt-get install build-essential

  git clone https://github.com/forj-oss/maestro
  #install puppet
  bash /opt/config/production/git/maestro/puppet/install_puppet.sh
  #install hiera
  bash /opt/config/production/git/maestro/hiera/hiera.sh
  #install puppet modules
  bash /opt/config/production/git/maestro/puppet/install_modules.sh
  export PUPPET_MODULES=/opt/config/production/git/maestro/puppet/modules:/etc/puppet/modules
  puppet apply --modulepath=$PUPPET_MODULES -e "include nodejs_wrap"

Install hubot:
----------------------

  mkdir -p /opt/hubot
  cd /opt/hubot
  npm install -g hubot coffee-script

Install nina-bot user:
----------------------

  hubot --create nina-bot
  cd nina-bot/
  git init
  git add .
  git commit -m "Initial commit"

  bin/hubot --name nina-bot

Setup XMP:
----------------------

vi package.json
Edit:

  "dependencies": {
        "hubot":         ">= 2.6.0 < 3.0.0",
         "hubot-scripts": ">= 2.5.0 < 3.0.0"
  },

To:

  "dependencies": {
    "hubot":         ">= 2.6.0 < 3.0.0",
    "hubot-scripts": ">= 2.5.0 < 3.0.0",
    "hubot-xmpp": ">= 0.1.11"
  },

npm install

Setup procfile:
  cd /opt/hubot/nina-bot
  sed 's/campfire/xmpp/' -i ./Procfile

Remove redis-brain.coffee config:
  sed 's/\"redis-brain.coffee\"\, //g' -i hubot-scripts.json


  cat > ./start-bot.sh <<BOTSTART
    #!/bin/bash
    if [ "$(id -u)" = "0" ] ;
    then
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
  BOTSTART

  chmod +x start-bot.sh

# /opt/hubot/nina-bot/node_modules/hubot-xmpp/src/xmpp.coffee


Create service
----------------------

  cp /etc/init.d/skeleton /opt/hubot/nina-bot/hubot.service.sh
  sed 's#^DAEMON=.*#DAEMON=/opt/hubot/nina-bot/bin/hubot --chdir /opt/hubot/nina-bot#' -i /etc/init.d/skeleton /opt/hubot/nina-bot/hubot.service.sh
  sed 's#^DAEMON_ARGS=.*#DAEMON_ARGS="-n nina-bot -a xmpp >> /var/log/hubot.log 2> \&1"#' -i /etc/init.d/skeleton /opt/hubot/nina-bot/hubot.service.sh
  sed 's#^NAME=.*#NAME=hubot#' -i /etc/init.d/skeleton /opt/hubot/nina-bot/hubot.service.sh
  sed 's/^DESC=.*/DESC="Hubot (nina-bot) Service"/' -i /etc/init.d/skeleton /opt/hubot/nina-bot/hubot.service.sh

  ln -s /opt/hubot/nina-bot/hubot.service.sh /etc/init.d/hubot
  chmod +x /opt/hubot/nina-bot/hubot.service.sh

  cat >  /opt/hubot/nina-bot/creds.env <<CREDS
    export HUBOT_XMPP_USERNAME='nina-bot@chat.forj.io'
    export HUBOT_XMPP_HOST='chat.forj.io'
    export HUBOT_XMPP_PORT=5222
    export HUBOT_XMPP_PASSWORD='DWpQQMY^M7fq'
    export HUBOT_XMPP_ROOMS='forj@conference.chat.forj.io'
    export HUBOT_XMPP_DISALLOW_TLS=true
  CREDS

  cat > /etc/default/hubot <<DEFAULTS
    . /opt/hubot/nina-bot/creds.env
  DEFAULTS

  chmod +x /opt/hubot/nina-bot/creds.env
  apt-get -y install chkconfig
  chkconfig -add hubot

  service hubot start


Start the service:
----------------------
  nohup ./start-bot.sh 2>&1 > /var/log/hubot.log &

Kill the service
----------------------
  ps -ef|grep node|grep hubot|awk '{print $2}' | xargs -i kill {}

Status:
----------------------
  ps -ef|grep node|grep hubot|awk '{print $2}'



TODO: still need to figure out how to get this into a service

Configure hpcloud cli
----------------------

  cd ~/git/maestro/puppet/modules/gardener/
  sudo gem1.8 install bundler --no-rdoc --no-ri
  sudo bundle install --gemfile Gemfile

  configure hpcloud cli

  Setup dev account : ' hpcloud account:setup dev'
  Test setup : 'hpcloud account:setup test-stable'
  PRO setup: 'hpcloud account:setup stable'

  hpcloud account:copy dev master
  hpcloud account:copy test-stable test
  hpcloud account:copy test-stable itg
  hpcloud account:copy stable pro
