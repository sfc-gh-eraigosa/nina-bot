
# commands:
#
# Query our kits...

spawn = require('child_process').spawn
util = require('util')
# -----------------------------------
# get correct forj registration url
# -----------------------------------
getForjPortalURL = (env) ->
  uri = ''
  switch env
    when "pro", "stable" then uri = "http://reg.forj.io:3135/devkit"
    when "test-stable","test","itg" then uri = "http://reg-test.forj.io:3134/devkit"
    when "dev", "master" then uri = "http://reg-dev.forj.io:3131/devkit"
    else uri = "http://reg-dev.forj.io:3131/devkit"
  return uri
# -----------------------------------
# generalized spawn method
# -----------------------------------
execute_hpcloud = (msg, branch) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a' , branch ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

# -----------------------------------
# remove forj from account
# -----------------------------------
execute_hpcloud_remove = (msg, forj, env) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', env, '--prefix', forj, '--remove-kit', '--nono' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

# -----------------------------------
# get node ip addresses
# -----------------------------------
execute_hpcloud_ip = (msg, kit, branch) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', branch, '--prefix', kit, '--only-ip' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

# -----------------------------------
# execute command
# -----------------------------------
execute_hpcloud_go = (msg) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', 'dev', '--nono', '--go' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Action done."

# -----------------------------------
# abort hpcloud command
# -----------------------------------
execute_hpcloud_abort = (msg) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', 'dev', '--nono', '--abort' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

# -----------------------------------
# who has a registered forj
# -----------------------------------
execute_kits_reg = (msg, branch) ->
  url = getForjPortalURL(branch)
  drush_spawn = spawn("registered.sh", [branch, url])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

# -----------------------------------
# how old are the forjs on this account
# -----------------------------------
execute_kits_age = (msg, branch) ->
  url = getForjPortalURL(branch)
  drush_spawn = spawn("serverage.sh", [branch, url])

  drush_spawn.stdout.on "data", (data) ->
    msg.send "#{data}"

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

# -----------------------------------
# aiml bot response
# -----------------------------------
aiml_response = (robot, botname , msg) ->
  msg_input = "#{msg.message.text}"
  if msg_input == ''
    return
  robot.logger.info "handel #{msg_input}"
  msgregx = new RegExp("^#{botname} ")
  msg_input = msg_input.replace msgregx, ""
  robot.logger.info "#{botname} responding to -> #{msg_input}"
  url   = "http://chat.forj.io/ProgramO/chatbot/conversation_start.php"
  say   = "?say=%22#{msg_input}%22"
  id    = "&convo_id=#{msg.envelope.user.name}"
  bot   = "&bot_id=1"
  formt = "&format=json"
  robot.logger.info "#{url}#{say}#{id}#{bot}#{formt}"
  robot.http("#{url}#{say}#{id}#{bot}#{formt}").get() (err, r, body) ->
    robot.logger.info "#{botname} r -> #{r.statusCode}"
    if !err
      data = JSON.parse(body)
      switch r.statusCode
        when 200
          robot.logger.info "#{botname} id -> #{data.convo_id}"
          robot.logger.info "#{botname} usersay -> #{data.usersay}"
          robot.logger.info "#{botname} botsay -> #{data.botsay}"
          msg.send data.botsay
        else
          robot.logger.error "#{botname} got non 200 response."
          msg.send "There was a problem with my connection to chatbot: #{res.statusCode}) #{data}."
          robot.emit "error: with #{botname}", err
    else
      robot.logger.error "#{botname} got error response."
      msg.send "There was a problem with chatbot: #{err}."
      robot.emit "error: with #{botname}", err

# -----------------------------------
# main robot forj brain
# -----------------------------------
module.exports = (robot) ->
#  robot.hear /kit/, (msg) ->
#    msg.send "Need help on kits? ask me."
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
# Commands:
#   catch all queries
###########################
#  resreg = new RegExp ".*", "i"
#  robot.logger.info "#{prefix} after regx"
#  robot.respond resreg, (msg) ->
  robot.catchAll (msg) ->
    try
      if new RegExp("#{prefix}").test(msg.message.text)
        robot.logger.info "#{prefix} responding to -> #{msg.message.text}"
        aiml_response robot, prefix, msg
    catch err
      robot.emit 'error: catching any message', err

###########################
#
###########################
