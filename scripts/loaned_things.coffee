## Track Things
# *Especially loaned stuff.*
# Shep can keep track of all the loaned things.
# Who did I loan X to? Did PERSON return X?
# idea from a Google Spreadsheet started by Saraswathi
#
# i have a(n) <thing> - Adds <thing> to your inventory
# i do not have a(n) <thing> - Remove <thing> from your inventory
# loan <user> my <thing> - Loans <thing> to <user> and saves the current time.
# <user> returned my <thing> - De-loans <thing> if <user> really was borrowing it.
# who has a(n) <thing>? - See if Shep knows about <thing> and who owns it.
# who has my <thing>? - See if your <thing> is on loan and to whom.
# all my things - get a list of everything you have that Shep knows about
# what have i borrowed? - What things does Shep know you are borrowing?
#

## THING
# {
#   id:CREATED_AT_TIMESTAMP
#   name:NAME_OF_THING
#   owner:WHOSE_IS_IT
#   loanee:SOMEONE_USER_NAME
#   loanedAt:[
#     {time:UNIX_TIME, loanee:'SOMEONE'}
#   ]
#   returnedAt:[
#     {time:UNIX_TIME, loanee:'SOMEONE'}
#   ]
# }

#### Things
# Based on karma.coffee from hubot-scripts.
class Things
  constructor: (@robot) ->
    # Initialize an empty cache
    @cache = {}

    # Trigger when Hubot has loaded its brain
    @robot.brain.on 'loaded', =>
      # Check to see if there already are some things
      if @robot.brain.data.things
        # And then set the cache accordingly.
        @cache = @robot.brain.data.things

  # Is this thing currently loaned to someone?
  availableToLoan: (thing, owner) ->
    (@cache[thing.id]['loanee']? || @cache[thing.id]['loanee'].length == 0)
  # Loan a thing by adding loanedAt:loanee and recording the time.
  loan: (thing, owner, loanee) ->
    @cache[thing.id]['loanee'] = loanee
    @cache[thing.id]['loanedAt'] ?= []
    @cache[thing.id]['loanedAt'].push({time:Date.now(), loanee:loanee})
    @robot.brain.data.things = @cache
    true
  # Return a thing by removing loanedTo and adding an element
  return: (thing, owner) ->
    loanee = thing.loanee
    thing.loanee = ''
    thing.returnedAt ?= []
    thing.returnedAt.push({time:Date.now(), loanee:loanee})
    @robot.brain.data.things = @cache
    true
  # remove a thing from the robot's brain
  remove: (thing, owner) ->
    delete @cache[thing.id]
    @robot.brain.data.things = @cache
    true
  # create an unloaned thing.
  create: (thing, owner) ->
    createdAt = Date.now()
    @cache[createdAt] = {id:createdAt, name:thing, owner:owner}
    @robot.brain.data.things = @cache
    true

  getThingsLoanedToMe: (loanee) ->
    things = []
    loaneeRegex = new RegExp loanee, "i"
    for own key, thing of @cache
      things.push(thing) if thing.loanee.match(loaneeRegex)?
    things

  # returns an object of things owner has and if they are loaned or not.
  getAllMyThings: (owner) ->
    myThings = []
    for own key, thing of @cache
      myThings.push(thing) if thing.owner.name is owner.name
    myThings

  listAllMyThings: (owner) ->
    allMyThings = @getAllMyThings(owner)
    inventory = for own key, thing of allMyThings
      loaned = ''
      if thing.loanedTo? and thing.loanedTo.length > 0
        loaned = " (loaned to #{loanedTo})"
      "#{thing.name}#{loaned}"
    "All Your Things: #{inventory.join(', ')}"

  allThings: ->
    thing for key, thing of @cache

  thingsLikeThis: (thingName, things=@allThings()) ->
    matches = []
    reg = new RegExp(thingName, "i")
    for thing in things
      match = thing.name.match(reg)
      if match?
        matches.push thing
      true
    matches

  myThingsLikeThis: (owner, thingName) ->
    myThings = @getAllMyThings owner
    @thingsLikeThis(thingName, myThings)

  getAmbiguousThingText: (things) ->
    "Be more specific, you've got #{things.length} things named like that: #{(thing.name for thing in things).join(", ")}"

module.exports = (robot) ->
  everything = new Things(robot)

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  #### loan a thing of yours to another user/person
  robot.respond /loan ([\w .-]+) my (.+)(\!?)/i, (msg) ->
    # Treat the thing name as a raw thing until we check the inventory.
    rawThing = msg.match[2]
    owner = msg.message.user
    name = msg.match[1]

    names = robot.brain.usersForFuzzyName(name)
    thingMatches = everything.myThingsLikeThis(owner, rawThing)

    # See if the owner only has one matching thing, do this.
    if thingMatches.length is 1
      thing = thingMatches[0]
      # We have an exact match
      if names.length is 1
        loanee = names[0].name
        if everything.availableToLoan(thing, owner)
          everything.loan(thing, owner, loanee)
          msg.send "You've loaned your #{thing.name} to #{loanee}."
        else
          msg.send "Your #{thing.name} is already loaned to #{thing.loanee}."
      # Be more specific please
      else if names.length > 1
        msg.send getAmbiguousUserText(names)
      # No such user. ADD FOLLOW UP
      else
        msg.send "I don't know anyone named #{name}"
    else if thingMatches.length > 1
      msg.send everything.getAmbiguousThingText(thingMatches)
    # Ok, the owner doesn't own any thing that matches that description.
    # ADD FOLLOW UP
    else
      msg.send "You don't own anything named like #{rawThing}. Please add it like so:"
      msg.send "shep i have a(n) #{rawThing}"
      msg.send "Or, teach me how to do this trick. http://github.com/stevenklise/shep"

  #### tell Shep that someone returned your thing
  robot.respond /([\w .-]+) returned my (.+)/i, (msg) ->
    owner = msg.message.user
    loanee = msg.match[1]
    rawThing = msg.match[2]

    loaneeRegex = new RegExp loanee, "i"

    thingMatches = everything.myThingsLikeThis(owner, rawThing)

    if thingMatches.length is 1
      thing = thingMatches[0]
      # If the thing is in fact loaned to who the owner said it is.
      if thing.loanee? and thing.loannee isnt '' and thing.loanee.match(loaneeRegex)?
        everything.return(thing, owner)
        msg.send "Ok, #{thing.name} is back in your posession."
      else
        msg.send "It seems you've"
  #### create a thing for yourself. So people can later try and borrow it.
  robot.respond /i have a?n? ?(.*)$/i, (msg) ->
    thing = msg.match[1]
    owner = msg.message.user

    if everything.create(thing, owner)
      msg.send "You now have a #{thing}."
    else
      msg.send "Something inexplicable happened..."
    msg.send everything.listAllMyThings(owner)

  #### remove a thing from your inventory
  robot.respond /i do not have a?n? ?(.*)$/i, (msg) ->
    rawThing = msg.match[1]
    owner = msg.message.user

    thingMatches = everything.myThingsLikeThis(owner, rawThing)

    if thingMatches.length is 0
      msg.send "I know."
    else if thingMatches.length is 1
      thing = thingMatches[0]
      everything.remove(thing, owner)
      msg.send "Ok, you no longer have #{thing.name}"
    else
      msg.send everything.getAmbiguousThingText(thingMatches)

  #### give a list of every thing an owner has noting who it is loaned to
  robot.respond /all my things/i, (msg) ->
    owner = msg.message.user
    msg.send everything.listAllMyThings(owner)

  #### What does Shep know that I've borrowed?
  robot.respond /what have I borrowed\?*/i, (msg) ->
    loanee = msg.message.user
    borrowedThings = everything.getThingsLoanedToMe(loanee)

    if borrowedThings.length is 0
      msg.send "You aren't currently borrowing anything as far as anyone has told me."
    else
      msg.send "Here are the things you are borrowing: #{(thing.name + ' from ' + thing.owner.name for thing in borrowedThings).join(", ")}"

  #### who has a `<thing>`?
  robot.respond /who has a?n? ?(.+)\?*$/i, (msg) ->
    rawThing = msg.match[1]

    thingMatches = everything.thingsLikeThis(rawThing)

    if thingMatches.length is 0
      msg.send "I haven't been told about any things like that."
    else
      msg.send "The following people have things like that: #{(thing.owner.name + ' (' + thing.name + ')' for thing in thingMatches).join(", ")}"

  #### who has my `<thing>`?
  robot.respond /who has my (.+)\?*$/i, (msg) ->
    owner = msg.message.user
    rawThing = msg.match[1]

    thingMatches = everything.myThingsLikeThis(owner, rawThing)

    if thingMatches.length is 1
      thing = thingMatches[0]
      if thing.loanee? or thing.loanee isnt ''
        lastLoan = thing.loanedAt[thing.loanedAt.length-1]
        msg.send "#{thing.loanee} has your #{thing.name}. You loaned it to them on #{robot.formatTime(lastLoan.time)}"
      else
        msg.send "Your #{thing.name} is not currently on loan, or at least you never told me."
    else if thingMatches.length is 0
      msg.send "You don't have anything named like #{rawThing}"
    else
      msg.send everything.getAmbiguousThingText(thingMatches)

## TODO:
# Ask follow up questions and respond to them using conversation.coffee.