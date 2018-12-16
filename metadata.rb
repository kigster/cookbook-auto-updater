name 'auto-updater'

maintainer 'Konstantin Gredeskoul'
maintainer_email 'kigster@gmail.com'
license 'MIT'

description 'Sets the timezone and periodically performs a full ' +
            'non-interactive upgrade on a schedule, sometimes requiring a reboot.'

source_url 'https://github.com/kigster/cookbook-auto-updater'
issues_url 'https://github.com/kigster/cookbook-auto-updater/issues'

chef_version '>= 12.1' if respond_to?(:chef_version)

gem 'colored2', '~> 3.1.2'

supports 'ubuntu'

version '0.3.2'

long_description <<~EOF
= DESCRIPTION:

This cookbook is meant to be used as part of the "baseline" on any Ubuntu system 
managed with Chef. 

Keeping systems up to date manually is difficult. Ubuntu makes it particularly hard,
because some of it's packages (i.e. GRUB) may require a manual interaction 
during an upgrade to complete. 

This cookbook offers a `auto_updater_update` resource which operates in a periodic fashion. Basically you tell it how often should it try to upgrade your system. Reasonable values are, perhaps a week or a month, and are configured via the `check_interval_hours`  attribute (see below).

However, if you applied this to all servers, and hypothetically one future update breaks the machine and prevents it from booting, you would want to make sure this  does not happen to all of your machines at once.

For this reason, this cookbook uniquely provides a second parameter: `node_check_delay_hours`,  which is a maximum "delta" that may be added or subtracted from the period. The way delta is computed is by hashing the node name, so that as long as the node name does not change, the delta for a particular host will always be the same. 

= EXAMPLE

For instance, say you specified:

 * check_interval_hours = 24 x 14 (perform update every 2 weeks)
 * node_check_delay_hours = 24 x 3 (add/subtract up to 3 days for each host)

A hash computed on the host name yields a number between `[ -node_check_delay_hours, node_check_delay_hours ]` and so for this host it might compute to -48. This means that the actual update will happen not every 14 days, but every 12 days (for this host only). Another host in your fleet might update every 16 days, and so on. 

The main idea is that if a risky upgrade goes bad, you have time to recover and you don't loose all of your hosts. 

= ATTRIBUTES

```ruby
# Set the time zone (optional)
default['auto-updater']['timezone'] = 'America/Los_Angeles'

# This must be set to true for auto-updater to work
default['auto-updater']['update']['enabled'] = true

# Time to wait between major updates take place
default['auto-updater']['update']['check_interval_hours'] = 24 * 15

# The maximum offset that will be added or substracted to the above
# attribute to decide the actual update frequency of a given host.
default['auto-updater']['update']['node_check_delay_hours'] = 24 * 3

# Setting this to true will force full update on every run, assuming there is
# something to update.
default['auto-updater']['update']['force_update_now'] = false

# Setting this to true disables reboot, even if some updates require it.
default['auto-updater']['update']['reboot_if_needed'] = true

# This is the field where the resource will save it's last time the
# update ran. This field is for internal use only.
default['auto-updater']['update']['last_update_at'] = nil

# Custom Packages
default['auto-updater']['packages'] = %w(
      htop
      silversearcher-ag
      zip
      libjemalloc-dev
      imagemagick
).map { |p| AutoUpdater::Package.new(p) }
```

= RESOURCES


 * `auto_update_updater`
 * `auto_update_timezone`

Here is an example of the updater:

```ruby
auto_updater_update 'Auto-Update of dev001' do
  node_name 'dev001'
  check_interval_hours 24 * 14
  node_check_delay_hours 24 * 3
  force_update_now false
  reboot_if_needed true
  action :run
end
```

EOF
