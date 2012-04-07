## Track Things
# *Especially loaned stuff.*
# Shep can keep track of all the loaned things.
# Who did I loan X to? Did PERSON return X?
# idea from a Google Spreadsheet started by Saraswathi


## THING
# {
#   name:NAME_OF_THING
#   owner:WHOSE_IS_IT
#   loanedTo:SOMEONE_USER_NAME
#   loanedAt:[
#     {time:UNIX_TIME, loanedTo:'SOMEONE'}
#   ]
#   returnedAt:[
#     {time:UNIX_TIME, loanedTo:'SOMEONE'}
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

  # Loan a thing by adding loanedAt:loanee and recording the time.
  loan: (thing, owner, loanee) ->
    "loaned"
  # Return a thing by removing loanedTo and adding an element
  return: (thing, owner, loanee) ->
    "returned"
  # remove a thing from the robot's brain
  remove: (thing, owner) ->
    "hi"
  # create an unloaned thing.
  create: (thing, owner) ->
    createdAt = Date.now()
    @cache[createdAt] = {name:thing, owner:owner}
    @robot.brain.data.things = @cache
    true
  # returns an object of things owner has and if they are loaned or not.
  getAllMyThings: (owner) ->
    myThings = []
    for own key, thing of @cache
      myThings.push(thing) if thing.owner.name is owner.name
    myThings

module.exports = (robot) ->
  everything = new Things(robot)

  #### create a thing for yourself. So people can later try and borrow it.
  robot.respond /i have a[n]? (.*)/i, (msg) ->
    thing = msg.match[1]
    owner = msg.message.user

    if everything.create(thing, owner)
      msg.send "You now have a #{thing}."
    else
      msg.send "Something inexplicable happened..."
    allMyThings = everything.getAllMyThings(owner)

    inventory = for own key, thing of allMyThings
      loaned = ''
      if thing.loanedTo is not 'undefined' && thing.loanedTo.length > 0
        loaned = " (loaned to #{loanedTo})"
      "#{thing.name}#{loaned}"
    msg.send "You also have the following: #{inventory.join(', ')}"

  #### give a list of every thing an owner has noting who it is loaned to
  robot.respond /all my things/i, (msg) ->
    owner = msg.message.user
    allMyThings = everything.getAllMyThings(owner)

    inventory = for own key, thing of allMyThings
      loaned = ''
      if thing.loanedTo is not 'undefined' && thing.loanedTo.length > 0
        loaned = " (loaned to #{loanedTo})"
      "#{thing.name}#{loaned}"
    msg.send "All Your Things: #{inventory.join(', ')}"


## TODO:
# <user> loaned me <thing>
# i loaned <user> my <thing>
# i returned <user> their <thing>
# <user> returned me <thing>
# where are my things? || who has my things?
# ....what have i borrowed?
# who has my <thing>