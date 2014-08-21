
# commands:
#
# Query our kits...

spawn = require('child_process').spawn
util = require('util')

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

  robot.respond /worldcup help/i, (msg) ->
    msg.send "nono-bot: worldcup matches (Pre-game|In-progress|Final)"
    msg.send "Query completed."

  robot.respond /worldcup last match of mexico/i, (msg) ->
    msg.send "Mexico 1 - 2 Netherlands ...... NO ERA PENAL!! :-("
    msg.send "Query completed."

  robot.respond /worldcup matches *(Pre-game|In-progress|Final)/i, (msg) ->
    status = msg.match[1]
    msg.send "Querying world cup API..."
    robot.http("http://worldcup.kimonolabs.com/api/matches?sort=startTime&status=" + status + "&includes=home,away&apikey=fd3d75707457b99674b4af3d02195cea")
      .get() (err, res, body) ->
        data = JSON.parse(body)
        switch res.statusCode
          when 200
            if data.length != 0
              for i in [0...data.length]
                msg.send "#{data[i].home.name} #{data[i].homeScore} - #{data[i].awayScore} #{data[i].away.name}"
              msg.send "Query completed."
            else
               msg.send "There are not matches"
               msg.send "Query completed."
          else
            msg.send "There was an error getting kit information (status: #{res.statusCode}) #{data}."
