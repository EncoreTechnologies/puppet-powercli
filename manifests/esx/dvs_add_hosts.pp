# @summary Resource that manages ESX DvSwitch Host membership
#
# @param esx_host
#   Name or IP address of the ESX host you would like joined to the dvswitch.
# @param dvswitch_name
#   Name of the dvswitch.
# @param nics
#   Array of NICs to be attached to the given dvswitch
#
# @example Usage This will attach vmnic2 & 3 to the dvs.
#   powercli::esx::dvs_add_hosts {'my-vmware-host.fqdn.tld':
#     esx_host      => 'my_esx_hostname_or_ip_here',
#     dvswitch_name => 'my_dvswitch_name_here',
#     nics          => [ 'vmnic2', 'vmnic3'],
#   }
define powercli::esx::dvs_add_hosts (
  $esx_host,
  $dvswitch_name,
  $nics,
  ) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  # For each phyysical nic to be added to the dvswitch..
  $nics.each | $nic | {
    # Add the current $nic to the $dvswitch_name if it is not already attached
    exec { "${name}: add ${nic} to ${dvswitch_name}":
      command  => template('powercli/powercli_esx_dvs_add_hosts.ps1.erb'),
      provider => 'powershell',
      onlyif   => template('powercli/powercli_esx_dvs_add_hosts_onlyif.ps1.erb'),
    }
  }
}
