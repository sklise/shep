module.exports = (robot) ->
  robot.hear /hi shep/, (msg) ->
    msg.send "Hi #{msg.message.user.name}"
  robot.respond /thank you$|thanks$/i, (msg) ->
    msg.send "You're welcome, #{msg.message.user.name}"