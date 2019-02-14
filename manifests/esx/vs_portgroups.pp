# @summary Resource that manages ESX vSwitch Portgroups
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
