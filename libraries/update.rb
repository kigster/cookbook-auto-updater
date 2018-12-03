module AutoUpdater
  # noinspection ALL
  class Update < Chef::Resource
    class << self
      def calc_secs_till_update(r)
        offset             = (Digest::MD5.hexdigest(hashed_name).gsub(/[a-f]/i, '').to_i % r.node_check_delay_hours) - r.node_check_delay_hours
        period_hours       = r.check_interval_hours + offset
        period_seconds     = period_hours * 60 * 60
        last_update        = node['auto-updater']['update']['last_update_at'] || 0
        second_till_update = (Time.now.to_i - last_update) - period_seconds
        return last_update, second_till_update
      end

      def apt_update(apt_args, env)
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

        execute 'apt-dist-update' do
          command "apt-get -y #{apt_args} dist-update"
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
      end

      def announce_next_update(node_name, second_till_update)
        days_till_update = -1.0 * second_till_update.to_f / (60 * 60 * 24).to_f
        color            = if days_till_update < 2
                             :red
                           elsif days_till_update < 7
                             :yellow
                           else
                             :green
                           end
        update_message   = "#{sprintf '%.2f', days_till_update} days"
        update_message   = update_message.send(color) if update_ + message.respond_to?(color)
        Chef::Log.warn("\n\n———————————→  NOTE: #{node_name} will auto-update in #{update_message} |————————————— \n\n")
      end

      def check_if_reboot_needed(r)
        if r.reboot_if_needed
          execute 'check if a reboot is required' do
            command 'echo reboot is scheduled'
            only_if 'sudo /usr/sbin/update-motd | grep restart'
            notifies(:request_reboot, 'reboot[reboot instance]', :delayed)
          end
        end
      end
    end

    resource_name :auto_updater_update

    property :update_message, String, name_property: true
    # How often (in hours) to check for updates, and if necessary update and reboot?
    property :check_interval_hours, Numeric, default: 24 * 30
    property :node_check_delay_hours, Numeric, default: 24 * 4 # +/- 4 days gives about 8 days total.
    property :reboot_if_needed, [true, false], default: false
    property :force_update_now, [true, false], default: false
    property :node_name, String

    def self.nodes_name(r)
      (r.node_name || node['name'])
    end

    action :run do
      r = new_resource

      require 'digest'
      require 'colored2'

      # computes the update days offset for this particular server, using servers name
      # and machine_id (if defined), and MD5 as a hashing function.
      last_update, second_till_update = calc_secs_till_update(r)

      host_name = nodes_name(r).bold.green

      if r.force_update_now || last_update.nil? || second_till_update > 0
        env = { 'DEBIAN_FRONTEND' => 'noninteractive' }
        Chef::Log.warn("\n\n========> WARNING! Auto-Update of host #{host_name} starting, reboot may be required...")
        Chef::Log.warn("\n\n========>          Last updated at #{last_update ? Time.at(last_update).to_s : '(never)'}")

        reboot('reboot instance') { action :nothing } unless r.reboot_if_needed

        apt_args = '-o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold"'
        apt_update(apt_args, env)

        # Save when we last updated.
        node.normal['auto-updater']['update']['last_update_at'] = Time.now.to_i

        check_if_reboot_needed(r)
      else
        announce_next_update(host_name, second_till_update)
      end
    end
  end
end
