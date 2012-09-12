# Description:

# Commands:
#   hi|hello|hey shep - teach Shep to say hi
#   shep thank you - Make Shep say you're welcome
module.exports = (robot) ->
  robot.hear /^(hi|hello|hey)( shep)?/i, (msg) ->
    msg.send "Hi #{msg.message.user.name}"
  robot.respond /thank you$|thanks$/i, (msg) ->
    msg.send "You're welcome, #{msg.message.user.name}"