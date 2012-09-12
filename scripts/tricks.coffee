# Description:
#   The (not really) secret tricks of Shep.
#
# Commands:
#   shep stop the hate - everyone chill
#   shep give me love - words of encouragement

module.exports = (robot) ->
  robot.respond /stop the hate/i, (msg) ->
    msg.send 'http://www.youtube.com/watch?v=KYfJ5GdtpEw'
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
  robot.respond /give me love/i, (msg) ->
    compliments = [
      "I really love your outfit today!",
      "Some days you play well, some days you learn well.",
      "It doesn't matter how slow you go as long as you keep going.",
      "You're alive, aren't you?",
      "Take some deep breaths and relax, everything will be fine.",
      "Keep calm and carry on.",
      "If I had arms, I'd give you a big hug.",
      "I love you.",
      "You know what they say, no pain no gain.",
      "No love for you. Failure is the best way to learn.",
      "You are my favorite ITPer.",
      "Go home. Get some sleep.",
      "You need to be exercising more.",
      "Why don't you stand up and stretch a bit?",
      "Uncertainty is an uncomfortable position. But certainty is an absurd one.",
      "I think all of your ideas are brilliant.",
      "What is love? Baby don't hurt me. Don't hurt me. No more.",
      "I'm busy right now, try me later.",
      "You can sign up for my office hours, I will explain love to you.",
      "You're good enough, you're smart enough, and doggone it, people like you."
    ]

    msg.send "#{msg.message.user.name}, #{msg.random(compliments)}"