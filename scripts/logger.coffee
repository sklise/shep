module.exports = (robot) ->
  robot.hear /.*/i, (msg) ->
    data = {user: "shep", project: "thesis2013", chat_user: msg.message.user, content: msg.message.text, timestamp: Date.now()}
    console.log(msg.message)
    msg.http('http://www.itpcakemix.com')
      .path("/add")
      .post(data)



    # msg.http("https://api.46elks.com")
    #   .path("/a1/SMS")
    #   .header("Authorization", auth)
    #   .post(data) (err, res, body) ->
    #     switch res.statusCode
    #       when 200
    #         msg.send "Sent sms to #{user.name}"
    #       else
    #         msg.send "Failed to send."
