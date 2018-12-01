module UbuntuSystem
  # noinspection ALL
  class Upgrade < Chef::Resource

    resource_name :ubuntu_system_upgrade

    property :upgrade_message, String, name_property: true
    property :interval, Numeric, default: 30
    property :stagger, Numeric, default: 5
    property :no_reboot, [true, false], default: false
    property :upgrade_now, [true, false], default: false
    property :node_name, String, required: true

    action :run do
      r = new_resource

      require 'digest'
      # computes the upgrade days offset for this particular server, using servers name
      # and machine_id (if defined), and MD5 as a hashing function.
      hashed_name       = r.node_name
      offset            = Digest::MD5.hexdigest(ha0shed_name).gsub(/[a-f]/i, '').to_i % r.stagger
      period_days       = r.interval - offset
      period_seconds    = period_days * 60 * 60 * 24
      last_upgrade      = node['ubuntu']['system']['upgrade']['last-upgraded-at'] || 0
      time_till_upgrade = (Time.now.to_i - last_upgrade) - period_seconds

      if r.upgrade_now || last_upgrade.nil? || time_till_upgrade > 0

        env = { 'DEBIAN_FRONTEND' => 'noninteractive' }

        apt_args = '-o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold"'

        Chef::Log.warn("\n\n========> WARNING! Auto-Upgrade of host #{hashed_name} starting, reboot may be required")
        Chef::Log.warn("\n\n========>          Last upgraded at #{last_upgrade ? Time.at(last_upgrade).to_s : '(never)'}")

        reboot('reboot instance') { action :nothing } unless r.no_reboot

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

        execute 'apt-auto-upgrade' do
          command "apt-get -y #{apt_args} upgrade"
          live_stream true
          environment env
          user 'root'
          cwd '/'
        end

        execute 'apt-dist-update' do
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

        node.normal['ubuntu']['system']['upgrade']['last-upgraded-at'] = Time.now.to_i

        unless r.no_reboot
          execute 'check if a reboot is required' do
            command 'echo reboot is scheduled'
            only_if 'sudo /usr/sbin/update-motd | grep restart'
            notifies(:request_reboot, 'reboot[reboot instance]', :delayed)
          end
        end
      else
        days_till_upgrade = -time_till_upgrade / (60 * 60 * 24)
        update_message    = "#{days_till_upgrade} days"
        color             = case days_till_upgrade
                            when 0...1
                              :red
                              break
                            when 2...7
                              :yellow
                              break
                            when 8...120
                              :green
                            end
        update_message = update_message.send(color) if update_+message.respond_to?(color)
        Chef::Log.warn("\n\n========> NOTE: #{r.node_name.bold.green} will auto-upgrade in #{update_message.send(color)}\n\n")
      end
    end
  end
end

