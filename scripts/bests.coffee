## Bests
# Tracks the best things (places, software, dishes, whatever) according to ITP.

class Thing
  constructor: (@id, @name, @becameBest, @supporters=[]) ->
    @
class Category
  constructor: (@category, @bests={}) ->
    @
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

  #### createThingOrAddSupporter
  createThingOrAddSupporter: (category, rawThing, user, callback) ->
    theBest = ""
    category = @robot.brain.data.bests[category]
    things = for own key, thing of category
      thing.name

    # This thing already exists, so add the user's name to the list of
    # supporters. And count the number of things.
    if rawThing in things
      # Empty array for matches (there should only be one)
      thingMatch = []

      # There must be an easier way to retrieve the matching thing without
      # iterating through the whole dang category.
      for key, thing of category
        if rawThing == thing.name
          thingMatch.push thing
        true

      # Save the id of the first thing. I could probably optimize away this
      # line if I make the above loop better.
      matchID = thingMatch[0].id

      # See if the current user has already made this claim, don't let the same
      # user.name increase the number of supporters.
      if user.name in category[matchID].supporters
        # Don't do anything, nothing has changed.
        theBest = "You've already told me that."
      # This user has not already supported this thing so we will add the user
      # as a supporter and see if this tips the scales.
      else
        # Add the user as a supporter
        category[matchID].supporters.push user.name
        # TODO: Check to see if this new supporter makes the thing the best.

    # Add a new thing. Most of the time there will be another thing in this
    # category but check just to make sure.
    else
      createdAt = Date.now()
      category[createdAt] = new Thing(createdAt, rawThing, 0, [user.name])
      # TODO: Check to make sure there is another thing with a supporter in
      # this category
      theBest = "new thing"
    callback(theBest, false)

  #### addBest
  # Takes a user, category and thing and creates a Best if it doesn't exist
  # and adds the user's name to the list of supporters. 
  addBest: (user, category, thing, callback) ->
    response = ""
    categories = @matchedCategoriesForFuzzyCategory(category)

    # Found exactly 1 matching category
    if categories.length == 1
      category = categories[0]
      @createThingOrAddSupporter category, thing, user, (theBest, thingBecameBest) ->
        response = theBest
        # if thingBecameBest
        #   response = "#{thing} is now the best #{category}!"
        # else if thing is theBest
        #   response = "ITP agrees that #{thing} is the best #{category}."
        # else
        #   response = "Sorry doggy, ITP thinks that #{theBest} is better than #{thing}."
    # No matches, create new category
    else if categories.length == 0
      @robot.brain.data.bests[category] = new Category category
      createdAt = Date.now()
      @robot.brain.data.bests[category][createdAt] = new Thing(createdAt, thing, createdAt, [user.name])

      response += "You're the first person to think there is a best #{category}, so we all agree that #{thing} is teh best."
    # Too many matches, tell the user.
    else
      response = @getAmbiguousText(categories)
    callback(response)

module.exports = (robot) ->
  # Create a bests instance.
  bests = new Bests robot

  robot.hear /no bests/i, (msg) ->
    robot.brain.data.bests = {}

  robot.hear /^make (.+) the best(.*)$/i, (msg) ->
    thing = msg.match[1].trim()
    category = msg.match[2].trim()
    # If the category was left blank, exit with message.
    if category.length == 0
      msg.send "the best what?"
    else
      bests.addBest msg.message.user, category, thing, (response) ->
        msg.send response


## TODO:
# make <thing> the best <category>
# best <category>
# all bests
# just alright <category>