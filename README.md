[![Build Status](https://travis-ci.org/kigster/cookbook-auto-updater.svg?branch=master)](https://travis-ci.org/kigster/cookbook-auto-updater)

# Chef Cookbook: Auto Updater

> Primarily for Ubuntu at the moment, as it uses `apt`. 

This Cookbook can be used on a recent Ubuntu image to:

 * Set it's timezone

 * Periodically run apt-update in a non-interactive way, forcing kernel updates and other security patches to be aggressively applied on a smart schedule. 

> This code is running in production in at least two companies.

## Staggering the Updates

Since updates may require rebooting the server, the resource will perform it only once every `interval-days` +/- a number between 0 and `stagger`. This number is obtained by performing a hash on the node name. This is done so that nodes do not all update (and possibly reboot) at the same time.

## Attribute Configuration

```ruby
# Set the time zone (optional)
default['auto-updater']['timezone'] = 'America/Los_Angeles'

# This must be set to true for auto-updater to work
default['auto-updater']['update']['enabled'] = true

# Time to wait between major updates take place
default['auto-updater']['update']['check_interval_hours'] = 24 * 15

# This delay is calculated using this number, plus/minus a semi-random number
# which is always the same for the same node. This ensures that if there is a
# dangerous upgrade that causes servers not to come back up, you won't end up
# with the entire fleet of servers down, but will start seeing them go down
# gradually.
default['auto-updater']['update']['node_check_delay_hours'] = 24 * 3

# Setting this to true will force full update on every run, assuming there is
# something to update.
default['auto-updater']['update']['force_update_now'] = false

# Setting this to true disables reboot, even if some updates require it.
default['auto-updater']['update']['reboot_if_needed'] = true

# This is the field where the resource will save it's last time the
# update ran. This field is for internal use only.
default['auto-updater']['update']['last_update_at'] = nil
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/cookbook-auto-updater](https://github.com/kigster/cookbook-auto-updater).

## License

&copy; 2018 Konstantin Gredeskoul, All rights reserved. MIT License.

