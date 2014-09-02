
# Description:
#   Watch an irc channel and repeat the message on the configured adapter.
#
# Dependencies:
#   npm install irc
#
# Configuration:
#   IRC_WATCH_SERVER    - hostname for irc server
#   IRC_WATCH_PORT      - port for irc server
#   IRC_WATCH_CHANNELS  - array list of channels to watch
#   IRC_WATCH_BOTNAME   - name of the bot to use
#   IRC_WATCH_BOTPASS   - password of the bot
#   IRC_WATCH_TALK_ROOM - the room to use when relaying messages on adapter
#   IRC_WATCH_RESP_PTRN - response pattern to use from watched irc channels
#                         use ${channel} to the channel name
#                         and ${from} for the name of the user the message is from.
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
irc = require "irc"

# -----------------------------------
# main robot forj brain
# -----------------------------------
module.exports = (robot) ->
  prefix = robot.alias or robot.name
# get config
  irc_watch_channels  = process.env.IRC_WATCH_CHANNELS or ''
  irc_watch_channels  = irc_watch_channels.split ',' if irc_watch_channels != '' 
  irc_watch_channels  = [] if irc_watch_channels == '' 
  irc_watch_server    = process.env.IRC_WATCH_SERVER or 'irc.freenode.net'
  irc_watch_port      = process.env.IRC_WATCH_PORT or 6667
  irc_watch_botname   = process.env.IRC_WATCH_BOTNAME or "#{prefix}-watch"
  irc_watch_botpass   = process.env.IRC_WATCH_BOTPASS or ''
  irc_watch_talk_room = process.env.IRC_WATCH_TALK_ROOM or ''
  irc_watch_resp_ptrn = process.env.IRC_WATCH_RESP_PTRN or '(${channel})/${from}> '
  # options
  options = {
      userName: irc_watch_botname,
      realName: "bot #{irc_watch_botname}",
      port: irc_watch_port,
      debug: false,
      showErrors: false,
      autoRejoin: true,
      autoConnect: true,
      channels: irc_watch_channels,
      secure: false,
      selfSigned: false,
      certExpired: false,
      floodProtection: false,
      floodProtectionDelay: 1000,
      sasl: false,
      stripColors: false,
      channelPrefixes: "&#",
      messageSplit: 512
  };


  # Create the bot name
  bot = new irc.Client irc_watch_server, irc_watch_botname, options
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

  bot.addListener "message", (from, channel, text, message) ->
    try
      irc_watch_resp_ptrn  # '(${channel})/${from} >'
      robot.logger.debug "nina-bot-watch got from    -> #{from}"
      robot.logger.debug "nina-bot-watch got channel -> #{channel}"
      robot.logger.debug "nina-bot-watch got text    -> #{text}"
      robot.logger.debug "nina-bot-watch got msg     -> #{message}"
      prompt = irc_watch_resp_ptrn.replace new RegExp("\$\{channel\}"), channel
      prompt = prompt.replace new RegExp("\$\{from\}"), from
      robot.messageRoom irc_watch_talk_room, "#{prompt}#{text}"
    catch err
      robot.emit 'error: response robot.enter'     


###########################
#
###########################
