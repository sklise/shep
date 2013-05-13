# Description:
#   ITP Thesis Week info script
#
# Commands:
#   whos next - who is presenting next
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

und = require "underscore"
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
    hours = date.getHours()

    timenum = hours*100+minutes

    msg.http('http://itp-thesis.s3.amazonaws.com/2013/schedule.json')
      .get() (err, res, body) ->
        sched = JSON.parse(body)
        time = (new Date)
        d = time.getDate()
        h = time.getHours()
        m = time.getMinutes()

        x = und.filter sched, (thing) ->
          timesplit = thing.time.split(":")
          thing.date is d and (h < timesplit[0] or (h <= timesplit[0] and m <= timesplit[1]))
        sorted = und.sortBy x, (thing) ->
          thing.time
        match = sorted[0]
        msg.send "#{match.student} is next at #{match.time}."


    # presentationTimes = []
    # for own time, pres of today
    #   presentationTimes.push parseInt(time)

    # upcoming = []
    # upcoming.push(time) for time in presentationTimes when time > timenum

    # # No time will be greater than this
    # min = 2400
    # min = time for time in upcoming when time < min

    # finalHour = Math.floor(min/100)
    # finalMinutes = min%100

    # if finalHour > 12
    #   finalHour = finalHour - 12
    # if finalMinutes < 10
    #   finalMinutes = "0#{finalMinutes}"

    # msg.send "#{today[min]['name']} is presenting at #{finalHour}:#{finalMinutes}. Thesis URL: #{today[min]['url']}"