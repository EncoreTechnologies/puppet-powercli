# @summary Resource that manages ESX Standard vSwitch portgroups
#
# @param hostname
#   The hostname of the host we want to create the vswitch on
# @param vswitch_name
#   The name of the vswitch we want to create portgroups on
# @param vlan
#   The VLAN ID of the portgroup being created
# @param portgroup
#   The name of the newly created portgroup
#
# @example Basic usage
#  powercli::esx::vs_portgroup {
#    hostname     => 'my-vmware-host.fqdn.tld',
#    vswitch_name => 'vswitch0',
#    vlan         => 10
#    portgroup    => 'vlan_10_portgroup_name'
#  }
define powercli::esx::vs_portgroup (
  $hostname,
  $vswitch_name,
  $vlan,
  $portgroup
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect
  
  $_cmd = "Get-VirtualSwitch -Standard -VMhost ${hostname} -Name ${vswitch_name} | New-VirtualPortgroup -Name ${portgroup} -VLanID ${vlan}"

  exec { "Create Portgroup ${portgroup} on host ${hostname}":
    command  => "${_connect}; ${_cmd} ",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_vs_portgroups_onlyif.ps1.erb'),
  }
}
