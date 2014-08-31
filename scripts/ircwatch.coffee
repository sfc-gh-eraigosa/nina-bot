
# Description:
#   Watch an irc channel and repeat the message on the configured adapter.
#
# Dependencies:
#   npm install irc
#
# Configuration:
#   IRC_WATCH_SERVER   - hostname for irc server
#   IRC_WATCH_PORT     - port for irc server
#   IRC_WATCH_CHANNELS - array list of channels to watch
#   IRC_WATCH_BOTNAME  - name of the bot to use
#   IRC_WATCH_BOTPASS  - password of the bot
#
# Commands:
#   None
#
# Notes:
#   Developed using blog post from http://davidwalsh.name/nodejs-irc
#

# -----------------------------------
# setup for irc watch
# -----------------------------------
// Create the configuration
var config = {
    channels: ["#forj", "#cdkdev"],
      server: "irc.freenode.net",
      botName: "nina-bot-watch"
};

// Get the lib
var irc = require("irc");

// Create the bot name
var bot = new irc.Client(config.server, config.botName, {
    channels: config.channels
});

# -----------------------------------
# main robot forj brain
# -----------------------------------
module.exports = (robot) ->
  prefix = robot.alias or robot.name
  robot.logger.info "processing #{prefix} aiml brain "

###########################
# handle errors
###########################
  robot.error (err, msg) ->
    if msg?
       robot.logger.error "handling -> #{err} : #{msg}"
       msg.reply "unable to continue. exception caught"
    else
       robot.logger.error "handling -> #{err.stack}"

###########################
# listen to all messages
###########################

  bot.addListener("message", function(from, to, text, message) {
  #    bot.say(config.channels[0], "¿Public que?");
      robot.emit message, {user: 'nina-bot'}
  });

###########################
#
###########################
