# Sets and Gets quotes from ITP faculty & students:
# idea from David Nolen & inspired by http://thequotabledano.com/
#
# quotable - see list of quotable people and a random quote
# quotable <person|year> - see a random quote from <person> or <year> (2012 = 2011-2012 school year)
# <person> said <quote> - add <quote> to <person>'s list of quotes.
# <person> did not say <quote> - remove <quote> from <person>'s list of quotes.

module.exports = (robot) ->
  getSchoolYear = ->
    date = new Date
    # September...
    if date.getMonth() < 9
      date.getFullYear()
    else
      date.getFullYear() + 1

  getSchoolYearStart = (year) ->
    Date.parse("9-1-#{year-1}")

  getRandomQuote = (msg, quoteObject, since=0) ->
    # Staff quotes
    if quoteObject.quotes?
      quotes = for id, quote of quoteObject.quotes
        quote
      chosen = msg.random(quotes)
      "#{quoteObject.name} said: #{chosen.quote} (#{robot.formatTime chosen.id})"
    # Recent Quotes
    else
      quotes = for id, value of quoteObject when (value.id >= getSchoolYearStart(since) && value.id < getSchoolYearStart(since+1))
        value
      if quotes.length is 0
        return "No one said anything in #{since}."
      chosen = msg.random(quotes)
      "#{chosen.person} said: #{chosen.quote} (#{robot.formatTime chosen.id})"

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  adminsForFuzzyName = (fuzzyName) ->
    lowerFuzzyName = fuzzyName.toLowerCase()
    admin for name, admin of (robot.brain.data['quotable:staff'] or {}) when (
      admin.name.toLowerCase().lastIndexOf(lowerFuzzyName, 0) == 0)

  matchedAdminsForFuzzyName = (fuzzyName) ->
    matchedAdmins = adminsForFuzzyName(fuzzyName)
    for admin in matchedAdmins
      return [admin] if admin.name.toLowerCase() is fuzzyName.toLowerCase()
    matchedAdmins
      
  robot.respond /quotable$/i, (msg) ->
    [adminArray, adminNames] = [[], []]
    for own name, admin of robot.brain.data['quotable:staff']
      adminArray.push {name:admin.name,quotes:admin.quotes}
      adminNames.push "#{name}"
    response = "I'm no parrot but I'm good at remembering what ITP's faculty and admins have said.\n"
    response += "Ask me for quotables from: #{adminNames.join(", ")}\n"
    response += getRandomQuote(msg, msg.random(adminArray))
    msg.send response

  robot.respond /quotable ([\w-]+)$/i, (msg) ->
    name = msg.match[1]
    admins = matchedAdminsForFuzzyName(name)
    
    if admins.length == 1
      admin = admins[0]
      if admin.quotes.length == 0
        msg.send "No one has told me any quotes from #{admin.name}! Tell me one like this: shep #{admin.name} said ______"
      else
        msg.send getRandomQuote(msg, admin)
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      since = (parseInt(name) || getSchoolYear())
      msg.send getRandomQuote(msg, robot.brain.data['quotable:people'], since)
      # msg.send "Sorry, I couldn't find a quotable person named #{name}."

  robot.respond /quotable ([\w-]+) bomb ?([0-9]{0,2})/i, (msg) ->
    count = if (msg.match[2] > 15) then 15 else (msg.match[2] || 5)
    name = msg.match[1]

    admins = matchedAdminsForFuzzyName(name)
    if admins.length == 1
      admin = admins[0]
      count = parseInt(if count > admin.quotes.length then admin.quotes.length else count) + 1
      results = []

      # While count !=0, decrement count.
      while count -= 1
        # Grab some random quote
        quote = msg.random(admin.quotes)
        # If the chosen quote is already in results, choose another and keep
        # doing so until that isn't the case.
        while quote in results
          quote = msg.random(admin.quotes)
        # We made it, now add the quote to the results array.
        results.push "#{admin.name} said: #{quote}"
        true
      msg.send results.join("\n")
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      msg.send "Sorry, I couldn't find a quotable person named #{name}."

  robot.respond /([\w-]+) said (.+)$/i, (msg) ->
    name = msg.match[1]
    quote = msg.match[2].trim()

    # Match the name to ITP admins
    admins = matchedAdminsForFuzzyName(name)
    # When there is a good match, add the quote.
    if admins.length == 1
      admin = admins[0]
      time = (new Date).getTime()
      admin.quotes[time] = {id:time, quote:quote}
      msg.send "Ok, #{admin.name} has said: #{quote}"
    # Too many matches, tell the user the possible names.
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    # No match found, save as generic quote.
    else
      robot.brain.data['quotable:people'] ||= {}
      now = new Date
      robot.brain.data['quotable:people'][now.getTime()] =
        id: now.getTime()
        person: name
        quote: quote
      msg.send "#{name}'s quote is saved as a generic quote."
      msg.send "OK, #{name} said #{quote} on #{now.getMonth()}/#{now.getDate()}/#{now.getFullYear()}."

  robot.respond /([\w-]+) did not say ?(.+)$/i, (msg) ->
    name = msg.match[1]
    badQuote = msg.match[2].trim()
    
    admins = matchedAdminsForFuzzyName(name)
    if admins.length == 1
      admin = admins[0]

      for id, value of admin.quotes
        if value.quote is badQuote
          delete admin.quotes[id]
          msg.send "Ok, #{admin.name} did not say #{badQuote}"
          return
      msg.send "I know."
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      msg.send "Sorry, I couldn't find a quotable person named #{name}."

  robot.respond /add quotable ([\w-]+)$/i, (msg) ->
    if msg.message.user.name == process.env.ADMIN_USER && process.env.ADMIN_USER != 'undefined'
      robot.brain.data['quotable:staff'] ||= {}
      admin = {name:msg.match[1], quotes:{}}
      robot.brain.data['quotable:staff'][admin.name] = admin
    else
      msg.send "Sorry doggy, you don't have the power for that."

  robot.respond /rm quotable ([\w]+)$/i, (msg) ->
    name = msg.match[1]
    if msg.message.user.name == process.env.ADMIN_USER && process.env.ADMIN_USER != 'undefined'
      robot.brain.data['quotable:staff'] ||= {}
      admins = matchedAdminsForFuzzyName(name)
      if admins.length == 1
        admin = admins[0]
        if (delete robot.brain.data['quotable:staff'][admin.name]) == true
          msg.send "#{admin.name} deleted successfully"
    else
      msg.send "Sorry doggy, you don't have the power for that."