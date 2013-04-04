# Description:
#   Basic manners to make Shep more pleasant to talk to.
#
# Commands:
#   hi|hello|hey shep - teach Shep to say hi
#   shep thank you - Make Shep say you're welcome
#
# Author:
#   stevenklise

module.exports = (robot) ->
  robot.respond /emoji/i, (msg) ->
    msg.send "http://www.emoji-cheat-sheet.com/"

  robot.hear /^(hi|hello|hey) ?([a-zA-Z0-9]+)?/i, (msg) ->
    recipient = msg.message.user.name
    recipient = msg.match[2] if msg.match[2]? and msg.match[2] isnt "shep"
    msg.send "Hi #{recipient}"

  robot.respond /thank you$|thanks$/i, (msg) ->
    msg.send "You're welcome, #{msg.message.user.name}"