module AutoUpdater
  module UpdateHelpers
    def print_update_status(node_display_name, second_till_update, last_update)
      days_till_update = -1.0 * second_till_update.to_f / (60 * 60 * 24).to_f
      color            = if days_till_update < 2
                           :red
                         elsif days_till_update < 7
                           :yellow
                         else
                           :green
                         end
      update_message   = "#{sprintf '%.2f', days_till_update} days"
      update_message   = update_message.send(color) if update_message.respond_to?(color)
      updated_days_ago = 1.0 * (Time.now.to_i - last_update).to_f / 3600.0 / 24.0
      updated_message  = last_update > 0 ? "#{'%.2f' % updated_days_ago} days ago" : 'never'
      Chef::Log.warn("\n\n")
      Chef::Log.warn("   #{node_display_name.bold.blue} will auto-update in #{update_message.bold.yellow}")
      Chef::Log.warn("   #{node_display_name.bold.blue} was last updated #{updated_message.bold.cyan}")
      Chef::Log.warn("\n\n")
    end

    def print_update_banner(last_update, node_display_name)
      last_update_msg = last_update ? "previous update was at #{Time.at(last_update).to_s.bold.blue})" : ''
      Chef::Log.warn("\n\n  ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n" +
                         "    " + "WARNING! ".bold.yellow + "\n" +
                         "        " + node_display_name.bold.green + " is due for auto-update.\n" +
                         "        " + last_update_msg + "\n" +
                         "  ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n\n")
    end

    def force_apt_upgrade(resource)
      reboot_resource = "reboot #{node.name}"
      reboot(reboot_resource) { action :nothing } if resource.reboot_if_needed

      env      = { 'DEBIAN_FRONTEND' => 'noninteractive' }
      apt_args = '-o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold"'

      execute 'apt-auto-update' do
        command 'apt-get -y update'
        live_stream true
        environment env
        user 'root'
        cwd '/'
      end

      execute 'dpkg --configure -a' do
        user 'root'
        cwd '/'
        ignore_failure true
      end

      execute 'apt-auto-update' do
        command "apt-get -y #{apt_args} update"
        live_stream true
        environment env
        user 'root'
        cwd '/'
      end

      execute 'apt-dist-upgrade' do
        command "apt-get -y #{apt_args} dist-upgrade"
        live_stream true
        environment env
        user 'root'
        cwd '/'
      end

      execute 'apt-autoremove' do
        command 'apt autoremove -y'
        environment env
        ignore_failure true
        action :run
      end

      # Save when we last updated.
      node.normal['auto-updater']['update']['last_update_at'] = Time.now.to_i

      if resource.reboot_if_needed
        execute 'check if a reboot is required' do
          command 'echo reboot is scheduled'
          only_if 'sudo /usr/sbin/update-motd | grep restart'
          notifies(:request_reboot, "reboot[#{reboot_resource}]", :delayed)
        end
      end
    end
  end
end
