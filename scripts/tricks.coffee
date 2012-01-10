# The (not really) secret tricks of Shep.
# These are only secret in that they are uncommented.

module.exports = (robot) ->
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
