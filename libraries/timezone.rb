module AutoUpdater
  # noinspection ALL
  class Timezone < Chef::Resource

    resource_name :auto_updater_timezone
    property :timezone, String, name_property: true

    action :run do
      r = new_resource

      package 'dbus'

      execute 'set_timezone' do
        command "/usr/bin/timedatectl set-timezone '#{r.timezone}' 2>/dev/null; true"
        not_if "/usr/bin/timedatectl | /bin/grep zone | /bin/grep #{r.timezone}"
        user 'root'
        ignore_failure true
      end
    end
  end
end
