# Class that manages DvSwitch Portgroups
define powercli::vcenter::dvs_portgroups (
  $dvswitch,
  $dvs_pgs,
) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $dvs_pgs.each | $pg_name, $vlan | {
    $vlan_id = $vlan['vlan']

    exec { "Create Portgroup ${pg_name} on dvswitch ${dvswitch}":
      command  => "${_connect};  Get-VDSwitch -Name ${dvswitch} | New-VDPortgroup -Name ${pg_name} -VLanID ${vlan_id}",
      provider => 'powershell',
      onlyif   => template('powercli/powercli_esx_dvs_portgroups_onlyif.ps1.erb'),
    }
  }
}
