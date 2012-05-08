# ITP Thesis Week info script
#
# whos next - who is presenting next
#

days = [
  'sunday',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday'
]

Util = require "util"

module.exports = (robot) ->
  # robot.respond /thesis week/i, (msg) ->
  #   date = new Date
  #   
  #   output = Util.inspect(robot.brain.data.thesisweek[date.getFullYear()], false, 4)
  #   msg.send output
  robot.respond /who\'?s next/i, (msg) ->
    date = (new Date)
    day = days[date.getDay()]
    minutes = date.getMinutes()
    hours = date.getHours() - 4

    timenum = hours*100+minutes

    today = robot.brain.data.thesisweek[date.getFullYear()]['schedule'][day]

    presentationTimes = []
    for own time, pres of today
      presentationTimes.push parseInt(time)

    upcoming = []
    upcoming.push(time) for time in presentationTimes when time > timenum

    # No time will be greater than this
    min = 2400
    min = time for time in upcoming when time < min

    finalHour = Math.floor(min/100)
    finalMinutes = min%100

    if finalHour > 12
      finalHour = finalHour - 12
    if finalMinutes < 10
      finalMinutes = "0#{finalMinutes}"

    msg.send "#{today[min]['name']} is presenting at #{finalHour}:#{finalMinutes}. Thesis URL: #{today[min]['url']}"