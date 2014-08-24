
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
# main robot forj brain
# -----------------------------------
module.exports = (robot) ->
#  robot.hear /kit/, (msg) ->
#    msg.send "Need help on kits? ask me."
  prefix = robot.alias or robot.name
  robot.logger.info "processing #{prefix} forj brain "

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
#   kit help
###########################
  robot.respond /kit help/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      msg.send "I can query your kit on any project (dev|dev-west|dev-east|itg|test|test-stable|pro|stable). Use those listed to do so:"
      msg.send "#{prefix}: kit list -- I will query dev-east project only."
      msg.send "#{prefix}: kit list on (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: who owns kit <id> on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: kits owned by <user@domain> on <dev>"
      msg.send "#{prefix}: kits registered on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: kits age on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: ip for kit <Kits> -- I will query dev project only."
      msg.send "#{prefix}: list IP for <Kits> from (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
      msg.send "I can do some stuff on your kit, as listed below:"
      msg.send "#{prefix}: remove kit <id> on <dev> -- I can remove kit only on master branch (dev-east)"
      msg.send "But I warn you. You will need to confirm me the action to do with 'go' OR 'abort'"
    catch err
      robot.emit 'error: kit help', err

###########################
# Commands:
#   forj help
###########################
  robot.respond /forj help/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      msg.send "I can query your forj on any project (dev|dev-west|dev-east|itg|test|test-stable|pro|stable). Use those listed to do so:"
      msg.send "#{prefix}: who owns forj <id> on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: forj list -- I will query dev-east project only."
      msg.send "#{prefix}: forj list on (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: forjs owned by <email@hp.com> on <dev>"
      msg.send "#{prefix}: forjs registered on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: forjs age on (dev|itg|test|test-stable|pro|stable)"
      msg.send "#{prefix}: ip for forj <forjs> -- I will query dev project only."
      msg.send "#{prefix}: list ip for <forjs> from (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
      msg.send "I can do some stuff on your forj, as listed below:"
      msg.send "#{prefix}: remove forj <id> on <dev> -- I can remove forj only on master branch (dev-east)"
      msg.send "But I warn you. You will need to confirm me the action to do with 'go' OR 'abort'"
    catch err
      robot.emit 'error: forj help', err

###########################
#
###########################
  robot.router.post "/hubot/backup-status", (req,res) ->
    room = req.body.room
    message = req.body.message

    # A way to get the user name sending a message to nono. Usable from the chat.
    # user = response.message.user.name

    robot.logger.info "Message '#{message}' received for room #{room}"

    user = robot.brain.userForId 'broadcast'
    user.room = room
    user.type = 'groupchat'

    #duser = util.inspect(user)

    if message
      robot.send user, "#{message}"

    # A way to send a private message to a user.
    #robot.send({user: {name: "chrisssss"}}, duser)

    # A way to reply to a user
    # robot.reply user message


    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end 'sent\n'

###########################
#
###########################
  robot.router.get "/hubot/users", (req,res) ->
    users = util.inspect(robot.brain.users())
    res.end "#{users}\n"

###########################
# Commands:
#   who owns kit <id> on <dev>
###########################
  robot.respond /who owns (kit|forj) ([a-z0-9]*) *on *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      kit = msg.match[2]
      if msg.match[3]?
        env = msg.match[3]
      else
        env = "dev"
      msg.send "Querying forj portal for..." + getForjPortalURL(env)
      robot.http(getForjPortalURL(env) + "/search/instance_id/#{kit}")
        .get() (err, res, body) ->
          data = JSON.parse(body)
          switch res.statusCode
            when 200
              if data.result.length != 0
                msg.send "The forj \"#{kit}\" belongs to '#{data.result[0].name}'"
                msg.send "Query finished."
              else
                msg.send "The forj \"#{kit}\" belongs to nobody."
                msg.send "Query completed."
            else
              msg.send "There was an error getting kit information (status: #{res.statusCode}) #{data.result}."
    catch err
      robot.emit 'error: who owns kit <id> on <dev>', err

###########################
# Commands:
#   kits owned by <email> on <dev>
###########################
  robot.respond /(kits|forjs) owned by ([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}) *on *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      email = msg.match[2]
      if msg.match[3]?
        env = msg.match[3]
      else
        env = "dev"
      msg.send "Querying forj portal for..." + getForjPortalURL(env)
      robot.http(getForjPortalURL(env) + "/search/email/#{email}")
        .get() (err, res, body) ->
          data = JSON.parse(body)
          switch res.statusCode
            when 200
              if data.result.length != 0
                for i in [0...data.result.length]
                  msg.send "The forj \"#{data.result[i].instance_id}\" belongs to '#{data.result[i].email}'"
                msg.send "Query completed."
              else
                 msg.send "There are not forjs registered by \"#{email}\"."
               msg.send "Query completed."
            else
              msg.send "There was an error getting forj information (status: #{res.statusCode}) #{data.result}."
    catch err
      robot.emit 'error: kits owned by <email> on <dev>', err

###########################
# Commands:
#   kit list on <dev>
###########################
  robot.respond /(give  *me |get )* *(kit  *list|list  *kit|list  *of  *kit)  *on  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable) *$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      branch = msg.match[3]
      execute_hpcloud msg, branch
    catch err
      robot.emit 'error: kit list on <dev>', err

###########################
# Commands:
#   forj list on <dev>
###########################
  robot.respond /(give  *me |get )* *(forj  *list|list  *forj|list  *of  *forj)  *on  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable) *$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      branch = msg.match[3]
      execute_hpcloud msg, branch
    catch err
      robot.emit 'error: forj list on <dev>', err

###########################
# Commands:
#   kit list
#   give me kit list
#   get kit list
###########################
  robot.respond /(give me |get )* *((kit(s)|forj)*  *list|list  *(of )* *(kit(s)|forj)*)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      branch = 'dev'
      execute_hpcloud msg, branch
    catch err
      robot.emit 'error: kit list', err

###########################
# Commands:
#   please remove kit <id> on <dev>
###########################
  robot.respond /(please )*(remove *(forj|kit)|(forj|kit) *remove) (([a-z0-9]|[a-z][a-z])*) *on *(dev|dev-west|dev-east)/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      kit = msg.match[3]
      env = msg.match[4]
      msg.send "env = #{env}"
      execute_hpcloud_remove msg, kit, env
    catch err
      robot.emit 'error: please remove forj <id> on <dev-west>', err

###########################
# Commands:
#   get kit list ip <id> from ?
###########################
  robot.respond /(give  *me |get )* *(details? *for|kit  *details?|list  *ip|ip  *list|kit  *ip|ip  *kit|ip  *for  *kit|kit  *ip|kit  *ip|ip)  *([a-z0-9 ]*)  *from *$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      msg.send "from what? master, test-stable or stable? please provide me more details."
    catch err
      robot.emit 'error: get kit list ip <id> from ?', err

###########################
# Commands:
#   get kit list ip <id> from <dev>
###########################
  robot.respond /(give  *me |get )* *(details? *for|kit  *details?|list  *ip|ip  *list|kit  *ip|ip  *kit|ip  *for  *kit|kit  *ip|kit  *ip|ip)  *([a-z0-9 ]*)  *from  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      kit = msg.match[3]
      branch = msg.match[4]
      execute_hpcloud_ip msg, kit, branch
    catch err
      robot.emit 'error: get kit list ip <id> from <dev>', err

###########################
# Commands:
#   get forj list ip <id> from <dev>
###########################
  robot.respond /(give  *me |get )* *(details? *for|forj  *details?|list  *ip|ip  *list|forj  *ip|ip  *forj|ip  *for  *forj|forj  *ip|forj  *ip|ip)  *([a-z0-9 ]*)  *from  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      forj = msg.match[3]
      branch = msg.match[4]
      execute_hpcloud_ip msg, forj, branch
    catch err
      robot.emit 'error: get forj list ip <id> from <dev>', err

###########################
# Commands:
#   get list ip on <id>
# Notes:
#   uses the dev account
###########################
  robot.respond /(give  *me |get )* *(details?|list  *ip|ip  *list|ip)(s)*  *(on|for|from)  *(kit|forj)  *([a-z0-9 ]* *)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      kit = msg.match[6]
      branch = 'dev'
      execute_hpcloud_ip msg, kit, branch
    catch err
      robot.emit 'error: get list ip on <id>', err

###########################
# Commands:
#   go
###########################
  robot.respond /(go|yes|oui|si)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      execute_hpcloud_go msg
    catch err
      robot.emit 'error: go', err

###########################
# Commands:
#   abort
###########################
  robot.respond /(abort( it)*|no|non)$/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      execute_hpcloud_abort msg
    catch err
      robot.emit 'error: abort', err

###########################
# Commands:
#   forjs registered on <dev>
###########################
  robot.respond /(kits|forjs) registered *on *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      branch = msg.match[2]
      execute_kits_reg msg, branch
    catch err
      robot.emit 'error: forjs registered on <dev>', err

###########################
# Commands:
#   forjs age on <dev>
###########################
  robot.respond /(kits|forjs) age *on *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    try
      robot.logger.info "#{prefix} responding to -> #{msg.match}"
      branch = msg.match[2]
      execute_kits_age msg, branch
    catch err
      robot.emit 'error: forjs age on <dev>', err


###########################
#
###########################
