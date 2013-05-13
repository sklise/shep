# Description:
#   ITP Thesis Week info script
#
# Commands:
#   whos next - who is presenting next
#

und = require "underscore"

module.exports = (robot) ->
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

        afterNow = und.filter sched, (thing) ->
          timesplit = thing.time.split(":")
          thing.date is d and (h < timesplit[0] or (h <= timesplit[0] and m <= timesplit[1]))
        sorted = und.sortBy afterNow, (thing) ->
          thing.time
        match = sorted[0]
        msg.send "#{match.student} is next at #{match.time}."