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


# Custom Packages
default['auto-updater']['packages'] = %w(
      htop
      silversearcher-ag
      zip
      libjemalloc-dev
      imagemagick
)
