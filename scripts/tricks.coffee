# The (not really) secret tricks of Shep.
# These are only secret in that they are uncommented.
# stop the hate - everyone chill

module.exports = (robot) ->
  robot.hear /life is never neat/i, (msg) ->
    msg.send 'Life is always bad: http://achewood.com/index.php?date=10282003'
  robot.respond /stop the hate/i, (msg) ->
    msg.send 'http://www.youtube.com/watch?v=KYfJ5GdtpEw'
  robot.respond /make [sS]pike angry/i, (msg) ->
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
  robot.respond /(rader me)/i, (msg) ->
    query = msg.match[3]
    msg.http("http://gdata.youtube.com/feeds/api/videos")
      .query({
        orderBy: "relevance"
        'max-results': 15
        alt: 'json'
        q: 'reedandrader'
      })
      .get() (err, res, body) ->
        videos = JSON.parse(body)
        videos = videos.feed.entry
        video  = msg.random videos

        video.link.forEach (link) ->
          if link.rel is "alternate" and link.type is "text/html"
            msg.send link.href
  