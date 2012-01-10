# Take arguments and make them a true thing on the internet
#
# http://true-cause-i-read-it-on-the-internet.net/
#
# make true <string> - Add statement to a url on true-cause-i-read-it-on-the-internet.net

module.exports = (robot) ->
  robot.hear /make true (.+)/i, (msg) ->
    assertion = msg.match[1] or 'cats-are-your-friends'
    assertion = assertion.split(' ').join('-')
    url = 'http://true-cause-i-read-it-on-the-internet.net/'+assertion
    msg.send url
