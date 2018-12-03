config = node['auto-updater']['update']

if config['enabled']
  auto_updater_update 'Automatic Update of Ubuntu Packages and Kernel' do
    node_name node['name'] # how frequently do we run the update in days?
    check_interval_hours config['check_interval_hours'] # how frequently do we run the update in days?
    node_check_delay_hours config['node_check_delay_hours'] # how much random +/- days do we want to add/subtract to avoid auto-upgrading all at once.
    force_update_now config['force_update_now'] # if this is set to true, forces to run update.
    reboot_if_needed config['reboot_if_needed'] # set this to true if you want to prevent automatic reboots.
  end
end

