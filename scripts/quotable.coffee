# Sets and Gets quotes from ITP faculty:
# idea from David Nolen & insipired by http://thequotabledano.com/
#
# quotable - see list of quotable people and a random quote
# quotable <admin> - see a random quote from <admin>
# <admin> said <quote> - add <quote> to <admin>'s list of quotes.

class Admin
  # Represents an admin (faculty or staff) from ITP.
  # Reserved for the core faculty and staff.
  # Frequent adjuncts (like Eric Rosenthal) can be added
  constructor: (@name, @quotes = []) ->
    @

module.exports = (robot) ->
  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  adminsForFuzzyName = (fuzzyName) ->
    lowerFuzzyName = fuzzyName.toLowerCase()
    admin for key, admin of (robot.brain.data.admins or {}) when (
      admin.name.toLowerCase().lastIndexOf(lowerFuzzyName, 0) == 0)

  matchedAdminsForFuzzyName = (fuzzyName) ->
    matchedAdmins = adminsForFuzzyName(fuzzyName)
    for admin in matchedAdmins
      return [admin] if admin.name.toLowerCase() is fuzzyName.toLowerCase()
    matchedAdmins
  
  #### shep add quotable <admin>
  # Utility method to add an Admin.
  # only responds to the ADMIN_USER
  robot.respond /add quotable ([\w-]+)$/i, (msg) ->
    if msg.message.user.name == process.env.ADMIN_USER && process.env.ADMIN_USER != 'undefined'
      robot.brain.data.admins ||= {}
      admin = new Admin msg.match[1]
      robot.brain.data.admins[admin.name] = admin
    else
      msg.send "Sorry doggy, you don't have the power for that."

  #### shep rm quotable <admin>
  # Remove an admin from storage
  # Careful, there is no way to undo this.
  robot.respond /rm quotable ([\w]+)$/i, (msg) ->
    name = msg.match[1]
    if msg.message.user.name == process.env.ADMIN_USER && process.env.ADMIN_USER != 'undefined'
      robot.brain.data.admins ||= {}
      admins = matchedAdminsForFuzzyName(name)
      if admins.length == 1
        admin = admins[0]
        if (delete robot.brain.data.admins[admin.name]) == true
          msg.send "#{admin.name} deleted successfully"
    else
      msg.send "Sorry doggy, you don't have the power for that."
      

  #### shep quotable
  # Shep tells the user what the "quotable" suite does and gives a list of
  # quotable people and ends with a random quote.
  robot.respond /quotable$/i, (msg) ->
    adminArray = []
    adminNames = for own key, admin of robot.brain.data.admins
      adminArray.push(admin)
      "#{admin.name}"
    response = "I'm no parrot but I'm good at remembering what ITP's faculty and admins have said.\n"
    response += "Ask me for quotables from: #{adminNames.join(", ")}\n"
    randomAdmin = msg.random(adminArray)
    response += "#{randomAdmin.name} said: #{msg.random(randomAdmin.quotes)}"
    msg.send response

  #### shep <admin> said <quote>
  # Add <quote> to <admin>'s quote list.
  robot.respond /([\w-]+) said (.+)$/i, (msg) ->
    name = msg.match[1]
    quote = msg.match[2].trim()
    
    admins = matchedAdminsForFuzzyName(name)
    if admins.length == 1
      admin = admins[0]
      admin.quotes.push(quote)
      msg.send "Ok, #{admin.name} has said: #{quote}"
      msg.send "As well as #{admin.quotes.length - 1} other things."
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      msg.send "Sorry, I couldn't find a quotable person named #{name}."

  #### shep <admin> did not say <quote>
  # Remove <quote> from <admin>'s quote list.
  # Must use the exact quote, I'm not going to worry about partial matches.
  robot.respond /([\w-]+) did not say ?(.+)$/i, (msg) ->
    name = msg.match[1]
    badQuote = msg.match[2].trim()
    
    admins = matchedAdminsForFuzzyName(name)
    if admins.length == 1
      admin = admins[0]
      admin.quotes = admin.quotes or []
      
      if badQuote not in quotes
        msg.send "I know."
      else
        admin.quotes = (quote for quote in admin.quotes when quote isnt badQuote)
        msg.send "Ok, #{admin} did not say #{badQuote}"
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      msg.send "Sorry, I couldn't find a quotable person named #{name}."

  #### shep quotable <admin>
  # Responds with a random quote from <admin>.
  robot.respond /quotable ([\w-]+)$/i, (msg) ->
    name = msg.match[1]
    admins = matchedAdminsForFuzzyName(name)
    
    if admins.length == 1
      admin = admins[0]
      if admin.quotes.length == 0
        msg.send "No one has told me any quotes from #{admin.name}! Tell me one like this: shep #{admin.name} said ______"
      else
        msg.send "#{admin.name} said: #{msg.random(admin.quotes)}"
    else if admins.length > 1
      msg.send getAmbiguousUserText(admins)
    else
      msg.send "Sorry, I couldn't find a quotable person named #{name}."

  #### shep quotable <admin> bomb <n>
  # Bombs with up to 15 quotes and if <n> is unspecified, 5.
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

  #### TODO:
  # 
  # shep quotable <admin> all => build urls that list all quotes.