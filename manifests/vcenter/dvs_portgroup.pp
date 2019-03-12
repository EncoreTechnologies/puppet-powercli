define powercli::vcenter::dvs_portgroup (
  $dvswitch,
  $vlan,
) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "Create Portgroup ${name} on dvswitch ${dvswitch}":
    command  => "${_connect};  Get-VDSwitch -Name ${dvswitch} | New-VDPortgroup -Name ${name} -VLanID ${vlan}",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dvs_portgroups_onlyif.ps1.erb'),
  }
}

