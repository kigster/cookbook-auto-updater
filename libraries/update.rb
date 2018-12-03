require_relative 'support/update_helpers'

Chef::Recipe.extend(::AutoUpdater::UpdateHelpers)
Chef::Resource.extend(::AutoUpdater::UpdateHelpers)
Chef::Resource.include(::AutoUpdater::UpdateHelpers)

module AutoUpdater
  class Update < Chef::Resource

    resource_name :auto_updater_update

    property :update_message, String, name_property: true
    # How often (in hours) to check for updates, and if necessary update and reboot?
    property :check_interval_hours, Numeric, default: 24 * 30
    property :node_check_delay_hours, Numeric, default: 24 * 4 # +/- 4 days gives about 8 days total.
    property :reboot_if_needed, [true, false], default: false
    property :force_update_now, [true, false], default: false
    property :node_name, String

    action :run do
      self.class.include(::AutoUpdater::UpdateHelpers)
      res = new_resource

      require 'digest'
      require 'colored2'

      node_display_name  = res.node_name || node.name
      offset             = (Digest::MD5.hexdigest(node_display_name).gsub(/[a-f]/i, '').to_i % res.node_check_delay_hours) - res.node_check_delay_hours
      period_hours       = res.check_interval_hours + offset
      period_seconds     = period_hours * 60 * 60
      last_update        = node['auto-updater']['update']['last_update_at'] || 0
      second_till_update = (Time.now.to_i - last_update) - period_seconds

      if res.force_update_now || last_update.nil? || second_till_update > 0
        print_update_banner(last_update, node_display_name)
        force_apt_upgrade(res)
      else
        print_update_status(node_display_name, second_till_update, last_update)
      end

      ruby_block 'check if restart is needed' do
        block do
          Chef::Log.warn("  #{node_display_name.bold.yellow} requires reboot")
        end
        only_if 'sudo /usr/sbin/update-motd | grep restart'
      end
    end
  end
end
