![](http://shep.info.s3.amazonaws.com/shep.jpg)

A chat bot for ITP built on [Hubot](http://hubot.github.com) and illustrated by
[Joe Kloc](http://joekloc.com).

## Contribute

Shep is written in [CoffeeScript](http://coffeescript.org) and built on
[Hubot](http://github.com/github/hubot). Check out those two projects if you're
new to all of this or jump right in and look at the file `scripts/maps.coffee`
for a simple example.

To contribute to Shep [fork](http://help.github.com/fork-a-repo/) this project,
make your changes and then issue a
[pull request](http://help.github.com/send-pull-requests/).

Shep is maintained by [Steve Klise](http://github.com/stevenklise).

## Development Notes

### Admin-only Scripts

Scripts for Shep can make use of `process.env.ADMIN_USER` to allow admin-only
interactions with Shep. For instance this is used in `scripts/quotable.coffee`
to add and remove people from the list of top-level quotable people.

`process.env.ADMIN_USER` is a single user, set by Shep's maintainer.

These scripts should not show up in `shep help`.

### Maintenance

There are scripts in `lib/maintenance` to clean up Shep's Redis brain and
otherwise keep Shep running nice and smooth.

## Changelog

### 1.0.0

- Merge 2 patches from Jedahan
- Additional documentation.
- Thesis Week script

### 0.8.1 - 2012/04/07

- Add method descriptions for Bests and LoanedThings

### 0.8.0 - 2012/04/07

- Use MTA status script from hubot-scripts
- Shep can now track what you have and what you have loaned
- Shep keeps track of quotable sayings from faculty and staff.
- Shep keeps track of the best things according to ITP.
- Bring Roles.coffee back.
- Bugfixes

### 0.7.0 - 2012/03/19

- Food, Beer, Parts maps
- True Cause I Read It On The Internet
- Crippled due to ITPIRL using only 1 IRC client.