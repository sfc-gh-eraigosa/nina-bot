
# commands:
#
# Query our kits...

spawn = require('child_process').spawn
util = require('util')
# get correct forj registration url
getForjPortalURL = (env) ->
  uri = ''
  switch env
    when "pro", "stable" then uri = "http://reg.forj.io:3135/devkit"
    when "test-stable","test","itg" then uri = "http://reg-test.forj.io:3134/devkit"
    when "dev", "master" then uri = "http://reg-dev.forj.io:3131/devkit"
    else uri = "http://reg-dev.forj.io:3131/devkit"
  return uri
# generalized spawn method
execute_hpcloud = (msg, branch) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a' , branch ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

execute_hpcloud_remove = (msg, forj, env) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', env, '--prefix', forj, '--remove-kit', '--nono' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

execute_hpcloud_ip = (msg, kit, branch) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', branch, '--prefix', kit, '--only-ip' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

execute_hpcloud_go = (msg) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', 'dev', '--nono', '--go' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Action done."

execute_hpcloud_abort = (msg) ->
  drush_spawn = spawn("hpcloud_cdk.sh", [ '--a', 'dev', '--nono', '--abort' ])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

execute_kits_reg = (msg, branch) ->
  url = getForjPortalURL(branch)
  drush_spawn = spawn("registered.sh", [branch, url])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."

execute_kits_age = (msg, branch) ->
  url = getForjPortalURL(branch)
  drush_spawn = spawn("serverage.sh", [branch, url])

  drush_spawn.stdout.on "data", (data) ->
    msg.send data

  drush_spawn.stderr.on "data", (data) ->
    msg.send "Err: #{data}"

  drush_spawn.on "exit", (code) ->
    msg.send "Query complete."


module.exports = (robot) ->
#  robot.hear /kit/, (msg) ->
#    msg.send "Need help on kits? ask me."

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

  robot.router.get "/hubot/users", (req,res) ->

    users = util.inspect(robot.brain.users())
    res.end "#{users}\n"

  robot.respond /who owns (kit|forj) ([a-z0-9]*) *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
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

  robot.respond /(kits|forjs) owned by ([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}) *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
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

  robot.respond /kit help/i, (msg) ->
    msg.send "I can query your kit on any project (dev|dev-west|dev-east|itg|test|test-stable|pro|stable). Use those listed to do so:"
    msg.send "nono-bot: who owns (kit|forj) <KIT> (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: kits owned by <email@hp.com>"
    msg.send "nono-bot: kit list -- I will query dev-east project only."
    msg.send "nono-bot: kit list on (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: kits registered (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: kits age (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: ip for kit <Kits> -- I will query dev project only."
    msg.send "nono-bot: list IP for <Kits> from (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
    msg.send "I can do some stuff on your kit, as listed below:"
    msg.send "nono-bot: remove kit <Kits> -- I can remove kit only on master branch (dev-east)"
    msg.send "But I warn you. You will need to confirm me the action to do with 'go' OR 'abort'"

  robot.respond /forj help/i, (msg) ->
    msg.send "I can query your forj on any project (dev|dev-west|dev-east|itg|test|test-stable|pro|stable). Use those listed to do so:"
    msg.send "nono-bot: who owns (forj) <FORJ> (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: forjs owned by <email@hp.com>"
    msg.send "nono-bot: forj list -- I will query dev-east project only."
    msg.send "nono-bot: forj list on (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: forjs registered (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: forjs age (dev|itg|test|test-stable|pro|stable)"
    msg.send "nono-bot: ip for forj <forjs> -- I will query dev project only."
    msg.send "nono-bot: list IP for <forjs> from (dev|dev-west|dev-east|itg|test|test-stable|pro|stable)"
    msg.send "I can do some stuff on your forj, as listed below:"
    msg.send "nono-bot: remove forj <forjs> -- I can remove forj only on master branch (dev-east)"
    msg.send "But I warn you. You will need to confirm me the action to do with 'go' OR 'abort'"

  robot.respond /(give  *me |get )* *(kit  *list|list  *kit|list  *of  *kit)  *on  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable) *$/i, (msg) ->
    branch = msg.match[3]

    execute_hpcloud msg, branch

  robot.respond /(give  *me |get )* *(forj  *list|list  *forj|list  *of  *forj)  *on  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable) *$/i, (msg) ->
    branch = msg.match[3]

    execute_hpcloud msg, branch

  robot.respond /(give me |get )* *(kit(s)*  *list|list  *(of )* *kit(s)*)$/i, (msg) ->
    branch = 'dev'

    execute_hpcloud msg, branch

  robot.respond /(please )*(remove  *kit|kit  *remove) ([a-z0-9 ]*) *on *(dev-west|dev-east)/i, (msg) ->
    kit = msg.match[3]
    env = msg.match[4]
    msg.send "env = " + env
    execute_hpcloud_remove msg, kit, env

  robot.respond /(please )*(remove  *forj|forj  *remove) ([a-z0-9 ]*) *on *(dev-west|dev-east)/i, (msg) ->
    forj = msg.match[3]
    env = msg.match[4]
    msg.send "env = " + env
    execute_hpcloud_remove msg, forj, env

  robot.respond /(give  *me |get )* *(details? *for|kit  *details?|list  *ip|ip  *list|kit  *ip|ip  *kit|ip  *for  *kit|kit  *ip|kit  *ip|ip)  *([a-z0-9 ]*)  *from *$/i, (msg) ->
    msg.send "from what? master, test-stable or stable? please provide me more details."

  robot.respond /(give  *me |get )* *(details? *for|kit  *details?|list  *ip|ip  *list|kit  *ip|ip  *kit|ip  *for  *kit|kit  *ip|kit  *ip|ip)  *([a-z0-9 ]*)  *from  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable)$/i, (msg) ->
    kit = msg.match[3]
    branch = msg.match[4]

    execute_hpcloud_ip msg, kit, branch

  robot.respond /(give  *me |get )* *(details? *for|forj  *details?|list  *ip|ip  *list|forj  *ip|ip  *forj|ip  *for  *forj|forj  *ip|forj  *ip|ip)  *([a-z0-9 ]*)  *from  *(dev|dev-west|dev-east|itg|test|test-stable|pro|stable)$/i, (msg) ->

    forj = msg.match[3]
    branch = msg.match[4]

    execute_hpcloud_ip msg, forj, branch

  robot.respond /(give  *me |get )* *(details?|list  *ip|ip  *list|ip)(s)*  *(on|for|from)  *(kit|forj)  *([a-z0-9 ]* *)$/i, (msg) ->
    kit = msg.match[6]
    branch = 'dev'

    execute_hpcloud_ip msg, kit, branch

  robot.respond /(go|yes|oui|si)$/i, (msg) ->
    execute_hpcloud_go msg

  robot.respond /(abort( it)*|no|non)$/i, (msg) ->
    execute_hpcloud_abort msg

  robot.respond /(kits|forjs) registered *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    branch = msg.match[2]

    execute_kits_reg msg, branch

  robot.respond /(kits|forjs) age *(dev|itg|test|test-stable|pro|stable|)/i, (msg) ->
    branch = msg.match[2]
    execute_kits_age msg, branch
