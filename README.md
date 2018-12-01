[![Build Status](https://travis-ci.org/kigster/cookbook-ubuntu-system.svg?branch=master)](https://travis-ci.org/kigster/cookbook-ubuntu-system)

# Ubuntu System

This Boss Cookbook can be used on a recent Ubuntu image to:

 * Set it's timezone
 * Periodically run apt-update in a non-interactive way, forcing kernel updates and other security patches to be aggressively applied on a smart schedule. 

> This code is running in production in at least two companies.

## Staggering the Updates

Since updates may require rebooting the server, the resource will perform it only once every `interval-days` +/- a number between 0 and `stagger`. This number is obtained by performing a hash on the node name. This is done so that nodes do not all update (and possibly reboot) at the same time.

## Attribute Configuration

```ruby
# Set the time zone for the server.
default['ubuntu']['system']['timezone'] = 'America/Los_Angeles'

# Globally disable these updates.
default['ubuntu']['system']['upgrade']['enabled'] = true

# if the server hasn't auto-upgraded in this many days — do it after this many days
default['ubuntu']['system']['upgrade']['interval-days'] = 15

# if we reboot all of our servers at the same time we'll most likely take the site
# down as well. Instead of auto-upgrading servers all on the same day (and possibly hour),
# let's stagger them across a configurable period, in this case — 7 days.
default['ubuntu']['system']['upgrade']['stagger'] = 3

# Setting this to true will force apt-get upgrade/dist-ugprade on every chef-run
# but reboot would only happen if actual updates were installed that require restart.
default['ubuntu']['system']['upgrade']['force'] = false

# Setting this to true disables reboot, even if some updates require it.
default['ubuntu']['system']['upgrade']['no_reboot'] = false

# This value will be set by the resource to last time it was updated.
# Resetting this to nil on the node forces auto-update just once.
default['ubuntu']['system']['upgrade']['last-upgraded-at'] = nil
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/cookbook-ubuntu-system](https://github.com/kigster/cookbook-ubuntu-system).

## License

&copy; 2018 Konstantin Gredeskoul, All rights reserved. MIT License.

