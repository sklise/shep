# Clean Brain
# Removes Users without any roles and never referenced in Loaned Items
# This script must be run when Shep is not running.

require 'uri'
require 'redis'
require 'json'

uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://l:6379')
@redis = Redis.new host:uri.host, port:uri.port, password:uri.password

# Get all users
brain = JSON.parse @redis.get('hubot:storage')

do_not_delete = []

brain['users'].each do |id, user|
  # Add users of 'bests' to a do-not-delete list
  brain['bests'].each do |category, bests|
    bests.each do |id, best|
      if best['supporters'] && (best['supporters'].include? user['name'])
        do_not_delete << user['id']
      end
    end
  end

  # Add users in 'things' to a do-not-delete list
  brain['things'].each do |id, thing|
    if thing['owner']['id'] == user['id']
      do_not_delete << user['id']
    end
  end
end

# Go through all users and delete if not on do-not-delete list and roles does
# not exist
brain['users'].delete_if do |id, user|
  !(!user['roles'].nil? && user['roles'].length == 0) && !do_not_delete.include?(user['id'])
end

@redis.set('hubot:storage',brain.to_json)