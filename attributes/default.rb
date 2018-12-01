
default['ubuntu']['system']['timezone'] = 'America/Los_Angeles'

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
