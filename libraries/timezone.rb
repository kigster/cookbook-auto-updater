module UbuntuSystem
  # noinspection ALL
  class Timezone < Chef::Resource

    resource_name :auto_updater_timezone
    property :timezone, String, name_property: true

    action :run do
      r = new_resource

      execute 'set_timezone' do
        command "timedatectl set-timezone #{r.timezone}"
        not_if "timedatectl | grep #{r.timezone}"
      end
    end
  end
end
