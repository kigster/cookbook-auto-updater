config = node['ubuntu']['system']['upgrade']

if config['enabled']
  ubuntu_system_upgrade 'Automatic Update of Ubuntu Packages and Kernel' do
    node_name node['name'] # how frequently do we run the upgrade in days?
    interval config['interval-days'] # how frequently do we run the upgrade in days?
    stagger config['stagger'] # how much random +/- days do we want to add/subtract to avoid auto-upgrading all at once.
    upgrade_now config['force'] # if this is set to true, forces to run upgrade.
    no_reboot config['no_reboot'] # set this to true if you want to prevent automatic reboots.
    action :run
  end
end
