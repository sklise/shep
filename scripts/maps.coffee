# Interacts with the Google Maps API.
#
# map me <query> - Returns a map view of the area returned by `query`.
# maps - List all ITP maps Shep knows about.
# feed me - Returns link to ITP Food Map (editable) (shortcut: "food").
# resource me - Returns an editable Google Map of parts and supply stores (shortcut: "parts").
# beer me - Returns an editable map of good places to drink after school (shortcut: "bars").

module.exports = (robot) ->
  # Respond with Google Food Map
  robot.respond /(feed me|food( map)*)/i, (msg) ->
    msg.send "I'm a dog, you should be feeding me #{msg.message.user.name}. Maybe at one of these places near school:"
    msg.send "http://maps.google.com/maps/ms?msid=212612765155761142119.0004b814e0a8125b6d4b0&msa=0"
    msg.send "Also, Ramen: http://maps.google.com/maps/ms?msid=216754842113290903564.0004b9302eae1eea1e701&msa=0&ll=40.734608,-73.986096&spn=0.039283,0.031843"
  robot.respond /parts|resource me/i, (msg) ->
    msg.send "Here's a map of parts/supplies stores in New York. Please add to it!"
    msg.send "http://maps.google.com/maps/ms?msid=208536369937245014825.000491f79657be48bfbbb&msa=0&ll=40.71851,-73.972664&spn=0.157168,0.15398"
  robot.respond /beer me|bars/i, (msg) ->
    msg.send "It's been a long day, these are good bars in the area, or for TNO."
    msg.send "http://maps.google.com/maps/ms?msid=212612765155761142119.0004b8da41b44f8656592&msa=0"
  robot.respond /list maps|maps/i, (msg) ->
    msg.http("http://itp-api.herokuapp.com/ilc/maps.js")
      .get() (err, res, body) ->
        msg.send "These are the maps I know about:"
        msg.send "#{map.title} : #{map.url}" for map in JSON.parse(body).maps

  # Google Maps queries
  robot.respond /(?:(satellite|terrain|hybrid)[- ])?map me (.+)/i, (msg) ->
    mapType  = msg.match[1] or "roadmap"
    location = msg.match[2]
    url      = "http://maps.google.com/maps?q=" +
               escape(location) +
              "&hl=en&sll=37.0625,-95.677068&sspn=73.579623,100.371094&vpsrc=0&hnear=" +
              escape(location) +
              "&t=m&z=11"

    msg.send url

