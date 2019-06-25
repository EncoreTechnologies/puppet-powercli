# @summary Resource that manages ESX vSwitch Portgroups
#
# @param vswitch
#   Name of the standard vswitch we wish to create portgroups on
# @param vs_pgs
#   Hash of Portgroup names and VLAN IDs
#
# @example Basic usage
#   powercli::esx::vs_portgroups {'my-vmware-host.fqdn.tld':
#     vswitch => 'my_standard_vswitch_name'
#     vs_pgs  => {
#       'vlan_10_portgroup_name_here' => {
#         vlan => 10
#       },
#       'vlan_11_portgroup_name_here' => {
#         vlan => 11
#       },
#     },
#   }
define powercli::esx::vs_portgroups (
  $vswitch,
  $vs_pgs,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $vs_pgs.each | $pg_name, $vlan | {
    $vlan_id = $vlan['vlan']
    $_cmd = "Get-VirtualSwitch -Standard -VMhost ${name} -Name ${vswitch} | New-VirtualPortgroup -Name ${pg_name} -VLanID ${vlan_id}"

    exec { "Create Portgroup ${pg_name} on host ${name}":
      command  => "${_connect}; ${_cmd} ",
      provider => 'powershell',
      onlyif   => template('powercli/powercli_esx_vs_portgroups_onlyif.ps1.erb'),
    }
  }
}
