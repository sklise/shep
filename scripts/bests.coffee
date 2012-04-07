## Bests
# Tracks the best things (places, software, dishes, whatever) according to ITP.

# make <thing> the best <category> - Add your name as a supporter of <thing> in <category>
# all bests - Get a list of the best <thing> of every <category>
# best <category> - Get what the best <thing> is of this <category>

#### Bests
# Based on karma.coffee from hubot-scripts.
class Bests
  constructor: (@robot) ->
    # Initialize an empty cache
    @cache = {}
    
    # Trigger when Hubot has loaded its brain
    @robot.brain.on 'loaded', =>
      # Check to see if there already are some things
      if @robot.brain.data.bests
        # And then set the cache accordingly.
        @cache = @robot.brain.data.bests
      else
        @robot.brain.data.bests = {}

  #### createThing
  # Creates a thing with `name` and parses `arguments[1]` with fallbacks.
  createThing: (name) ->
    args = arguments[1] || {}
    {
      id: args['id'] || Date.now()
      name: name
      becameBest: args['becameBest'] || 0
      supporters: args['supporters'] || []
    }

  # From roles.coffee
  # Helpers to identify Categories.
  getAmbiguousText: (categories) ->
    "Be more specific, I know #{categories.length} categories named like that: #{(category for category in categories).join(", ")}"

  categoriesForFuzzyCategory: (fuzzyCategory) ->
    lowerFuzzyCategory = fuzzyCategory.toLowerCase()
    category for category, data of @robot.brain.data.bests when (
      category.toLowerCase().lastIndexOf(lowerFuzzyCategory, 0) == 0)

  matchedCategoriesForFuzzyCategory: (fuzzyCategory) ->
    matchedCategories = @categoriesForFuzzyCategory(fuzzyCategory)
    for category in matchedCategories
      return [category] if category.toLowerCase() is fuzzyCategory.toLowerCase()
    matchedCategories

  getCategoryFromName: (categoryName) ->
    @robot.brain.data.bests[categoryName]

  #### getTheBest(category)
  # Pass in a category object and figure out what the best is and return its
  # name and becameBest time.
  getTheBest: (category) ->
    # Keep track of the maximum number of supporters seen and what that thing
    # was that had the most supporters.
    maxSupporters = 0
    theBest = {}

    # Loop through all of the things of the category
    for own key, thing of category
      # If the length of supporters is strictly greater than `maxSupporters`
      # set new values for `maxSupporters` and `theBest`
      if maxSupporters < (thing.supporters || []).length
        maxSupporters = thing.supporters.length
        theBest = {name:thing.name, becameBest:thing.becameBest, supporters:thing.supporters}
      # Or if `maxSupporters` is the same as this thing, grab the thing with
      # the largest `becameBest` value.
      else if maxSupporters == (thing.supporters || []).length
        if theBest.becameBest < thing.becameBest
          theBest = {name:thing.name, becameBest:thing.becameBest, supporters:thing.supporters}

    theBest

  #### createThingOrAddSupporter

  createThingOrAddSupporter: (categoryName, rawThing, user, callback) ->
    response = ""
    category = @robot.brain.data.bests[categoryName]
    things = for own key, thing of category
      thing.name.toLowerCase()

    # This thing already exists, so add the user's name to the list of
    # supporters. And count the number of things.
    if rawThing.toLowerCase() in things
      # Empty array for matches (there should only be one)
      thingMatch = []

      # There must be an easier way to retrieve the matching thing without
      # iterating through the whole dang category.
      for key, thing of category
        if rawThing.toLowerCase() == thing.name.toLowerCase()
          thingMatch.push thing
        true

      # Save the id of the first thing. I could probably optimize away this
      # line if I make the above loop better.
      matchID = thingMatch[0].id

      thing = thingMatch[0]
      theBestThing = @getTheBest(category)

      # See if the current user has already made this claim, don't let the same
      # user.name increase the number of supporters.
      if user.name in thing.supporters
        # Don't do anything, nothing has changed.
        response = "You've already told me you think that."
        # Now tell the user what is currently the best.
        if theBestThing.name == thing.name
          response += " And ITP agrees with you that #{thing.name} is the best #{categoryName}"
        else
          response += " Sorry but ITP tends thinks that #{theBestThing.name} is better"
      # This user has not already supported this thing so we will add the user
      # as a supporter and see if this tips the scales.
      else
        # Add the user as a supporter
        thing.supporters.push user.name

        # Does thing now have more supporters than theBestThing?
        if theBestThing.supporters.length < thing.supporters.length
          # Seems it does, so update becameBest.
          thing.becameBest = Date.now()
          response = "Oh rad, you've just made #{thing.name} the best #{categoryName}."

    # Add a new thing. Most of the time there will be another thing in this
    # category but check just to make sure.
    else
      createdAt = Date.now()
      category[createdAt] = @createThing rawThing,
        id:createdAt
        becameBest:0
        supporters:[user.name]
      count = 0
      categoryHasASupporter = false

      # Be sure that there are other things in this category
      for key, thing of category
        categoryHasASupporter = true if thing.supporters.length >= 1
        count += 1
        true

      # If there is not a single supporter in this category or no other things
      # make this new thing the best.
      if !categoryHasASupporter || count = 0
        category[createdAt]['becameBest'] = createdAt
        response = "#{categoryHasASupporter} Oh rad, you've just made #{rawThing} the best #{categoryName}."
      # Otherwise tell them whatever thing is better is better.
      # TODO: Will this break? If there's nothing else in the category then
      # there would be no theBestThing.
      else
        theBestThing = @getTheBest(category)
        response = "Sorry but ITP tends thinks that #{theBestThing.name} is better."
    callback(response)

  #### addBest
  # Takes a user, category and thing and creates a Best if it doesn't exist
  # and adds the user's name to the list of supporters.

  addBest: (user, category, thing, callback) ->
    response = ""
    categories = @matchedCategoriesForFuzzyCategory(category)

    # Found exactly 1 matching category
    if categories.length == 1
      category = categories[0]
      # Delegate work to another function to keep things a bit shorter.
      @createThingOrAddSupporter category, thing, user, (whatHappened) ->
        response = whatHappened
    # No matches, create new category
    else if categories.length == 0
      @robot.brain.data.bests[category] = {}
      thingId = Date.now()

      # Create the thing. Since this is a new category set `becameBest` to the
      # current time.
      @robot.brain.data.bests[category][thingId] = @createThing thing, 
        id:thingId
        becameBest:thingId
        supporters:[user.name]

      # Make the user feel real special.
      response = "You're the first person to think there is a best #{category}, so we all agree that #{thing} is teh best."
    # Too many matches, tell the user.
    else
      response = @getAmbiguousText(categories)
    # Send the response to the given callback
    callback(response)

module.exports = (robot) ->
  # Create a bests instance.
  bests = new Bests robot

  robot.formatTime = (unixtime) ->
    d = new Date(unixtime)
    "#{d.toDateString()}"

  #### Make `<thing>` the best `<category>`
  # Creates `<thing>` and `<category>` if they don't exist. Adds msg.message.user
  # as a supporter or tells the user they already support the `<thing>`. Finally
  # tally up the supporters of every thing and tell the user which is really
  # "the best."
  robot.respond /make (.+) the best(.*)$/i, (msg) ->
    # Get `<thing>` and `<category>` with no edge white space.
    thing = msg.match[1].trim()
    category = msg.match[2].trim()
    # If the category was left blank, exit with message.
    if category.length == 0
      msg.send "the best what?"
      msg.send "Tell me again with 'shep make <thing> the best <category>'"
    else
      # We've got a category and a thing. Send everything to the addBest method
      # send the response.
      bests.addBest msg.message.user, category, thing, (response) ->
        msg.send response

  robot.respond /all bests/i, (msg) ->
    for category, things of robot.brain.data.bests
      theBest = bests.getTheBest(things)
      msg.send "#{theBest.name} is the best #{category} since #{robot.formatTime(theBest.becameBest)}"
      true

  robot.respond /best (.*)$/i, (msg) ->
    categoryName = msg.match[1].trim()
    categories = bests.matchedCategoriesForFuzzyCategory(categoryName)

    # Found exactly 1 matching category
    if categories.length == 1
      categoryName = categories[0]
      category = bests.getCategoryFromName(categoryName)
      theBest = bests.getTheBest(category)
      msg.send "#{theBest.name} is the best #{categoryName} as of #{robot.formatTime(theBest.becameBest)}"
    else if categories.length > 1
      msg.send bests.getAmbiguousText(categories)
    else
      msg.send "No one has said a word about a best #{categoryName}."

## TODO:
# just alright <category>