# Description:
#   The (not really) secret tricks of Shep.
#
# Commands:
#   shep stop the hate - everyone chill

module.exports = (robot) ->
  robot.hear /hi shep/, (msg) ->
    msg.send "Hi #{msg.message.user.name}"
  robot.respond /thank you$|thanks$/i, (msg) ->
    msg.send "You're welcome, #{msg.message.user.name}"
  robot.respond /stop the hate/i, (msg) ->
    msg.send 'http://www.youtube.com/watch?v=KYfJ5GdtpEw'
  robot.respond /make spike angry/i, (msg) ->
    msg.send 'http://sk-downloads.s3.amazonaws.com/angry.png'
  robot.respond /(look a cat|cat)(\!*)/i, (msg) ->
    # Huge chunks from the bundled youtube.coffee script
    params =
      orderBy: "relevance"
      'max-results': 15
      alt: 'json'
      q: 'cat'
    msg.http('https://gdata.youtube.com/feeds/api/videos')
      .query(params)
      .get() (err, res, body) ->
        videos = JSON.parse(body)
        videos = videos.feed.entry
        video = msg.random videos

        video.link.forEach (link) ->
          if link.rel is "alternate" and link.type is "text/html"
            msg.send link.href