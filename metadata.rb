name 'auto-updater'

maintainer 'Konstantin Gredeskoul'
maintainer_email 'kigster@gmail.com'
license 'MIT'
description 'Performs an non-interactive apt-update on a schedule, sometimes requiring a reboot'
version '0.1.1'
chef_version '>= 12.1' if respond_to?(:chef_version)

gem 'colored2', '~> 3.1.2'

supports 'ubuntu'
