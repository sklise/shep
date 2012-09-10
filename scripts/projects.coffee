# Description:
#   Projects, or URLs I'm Working On
#
# Commands:
#   i made <url> - add a url for a thing you made.
#   i did not make <url> - Remove a url from your list of urls
#   i am making <url> - Submit a url to a thing you are working on
#   i finished <url> - Change a url for a thing from working on to completed.

#   made this week - Get a list of what people at ITP have made this week.
#   making this week - Get a list of what people are working on this week
#   what <user> made - Returns just the things that the given user made
#   what <user> is making - Returns just the things the given user is making.

#### Projects
class Projects
  constructor: (@robot) ->
    @cache = {}

    # Trigger when Hubot has loaded its brain
    @robot.brain.on 'loaded', =>
      # Check to see if there already are some projects
      if @robot.brain.data.projects
        # And then set the cache accordingly.
        @cache = @robot.brain.data.projects

  # Takes a string and splits it into a title and a url and sends the results
  # to a new Project object. Does not save the project to the cache.
  #
  # rawString : A string from a message to Shep that may contain a url and or
  #             title of a project or both.
  #
  # Returns a Project object without ID or creator
  parseStringToProject: (rawString) ->
    urlRegex = ///
      (https?://)?                          # http is optional
      ([a-zA-Z0-9-_\.]+)                    # non-top-level domains
      \.
      (com|net|org|edu|ch|co|gd|in|info|ly|se|)   # top-level domain
      ([0-9a-zA-Z\/=+\-_:]+)?               # path
    ///
    url = rawString.match(urlRegex)
    url ?= [""]
    urlStart = rawString.lastIndexOf(url[0]) - 1
    urlEnd = urlStart + url[0].length + 1
    beforeUrl = rawString[0..urlStart].trim()
    afterUrl = rawString[urlEnd..rawString.length].trim()
    "#{beforeUrl} : #{url[0]} : #{afterUrl}"
    url = if url[0][0..3] == 'http' then url[0] else "http://#{url[0]}"
    {
      url: url
      title: beforeUrl
      description: afterUrl
      complete: true
    }

  # Get the list of projects belonging to a user.
  #
  # userName  : The string value of msg.message.user.name or some other
  #             verified user object
  #
  # Returns an array of project objects
  getProjectsOfUser: (user) ->
    projects = []
    for own key, project of @cache
      projects.push(project) if project.creator.name is user.name
    projects

  # Sets creator and id of an incomplete project object.
  #
  # project : an incomplete project object w/o an id or creator.
  # user    : a user object from robot.brain.data.users
  #
  # Returns nothing.
  addProjectToUser: (project, user) ->
    project.id = Date.now()
    project.creator = user
    @cache[project.id] = project
    @robot.brain.data.projects = @cache
    true

  # Check the title, url and description of a project against the cache to see
  # if a match exists.
  #
  # project : object consisting of title, url and description.
  # user    : a standard Hubot user object.
  #
  # Returns true if no match for this project is found and false otherwise.
  isProjectNew: (project, user) ->
    isNew = true

    usersProjects = @getProjectsOfUser(user)

    for existingProject in usersProjects
      isNew = false if project.title == existingProject.title
      isNew = false if project.url == existingProject.url
      true
    isNew

module.exports = (robot) ->
  projectIndex = new Projects(robot)

  robot.respond /i made (.*).?$/i, (msg) ->
    user = msg.message.user
    rawProject = msg.match[1]
    project = projectIndex.parseStringToProject(rawProject)

    # Ensure this is a new project.
    if projectIndex.isProjectNew(project, user)
      projectIndex.addProjectToUser(project, user)
      msg.send "Awesome! #{user.name} made #{project.title} #{project.url}"
    else
      msg.send "I know."

  robot.respond /i did not make (.*).?$/i, (msg) ->
    msg.send "cool"
  robot.respond /i am making (.*).?$/i, (msg) ->
    msg.send "cool"
  robot.respond /i finished (.*).?$/i, (msg) ->
    msg.send "cool"
  robot.respond /made this week/i, (msg) ->
    msg.send "cool"
  robot.respond /making this week/i, (msg) ->
    msg.send "cool"
  robot.respond /what ([\w .-]+) made/i, (msg) ->
    msg.send "cool"
  robot.respond /what ([\w .-]+) is making/i, (msg) ->
    msg.send "cool"

# TODO:
# Improve title formation of projects