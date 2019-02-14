# Class that manages ESX DvSwitch Host membership
define powercli::esx::dvs_add_hosts (
  $dvswitch_name,
  $dvswitch_nic_defaults,
  $overrides
  ) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  # This returns null if the host does not have 'vswitches' (both standard and distributed) overrides set.
  $current_server_overrides = $overrides[$name]['vswitches']

  #if the server had ANY overrides for vswitches...
  if $current_server_overrides {

    # Select the dvswitch overrides only (if any exist on the current host)
    $current_server_dvswitch_overrides = $current_server_overrides.filter | $keys, $values | { $keys == $dvswitch_name }

  }

  # The merge compares the list of defaults to the list of overrides (if there are any).
  # If there are overrides present for the host, the defaults are IGNORED for that host ONLY.
  # The merge produces a hash where the key is the dvswitch name and the data physical uplink list.
  $dvswitch_merge = deep_merge($dvswitch_nic_defaults, $current_server_dvswitch_overrides)

  # List of physical nics for our host (will be the list of override nics if the host has them specified, otherwise will be the defaults)
  $physical_nics = $dvswitch_merge[$dvswitch_name]['nics']

  # For each phyysical nic to be added to the dvswitch..
  $physical_nics.each | $nic | {
    # Add the current $nic
    exec { "${name}: add ${nic} to ${dvswitch_name}":
      command  => template('powercli/powercli_esx_dvs_add_hosts.ps1.erb'),
      provider => 'powershell',
      onlyif   => template('powercli/powercli_esx_dvs_add_hosts_onlyif.ps1.erb'),
    }
  }
}
