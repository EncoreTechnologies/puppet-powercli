# @summary Resource that manages distributed virtual switch (dvs) portgroups
#
# @param dvswitch
#  Name of the dvs we wish to create portgroups on
# @param vlan
#   VLAN ID of the portgroup we wish to create
#
# @example Basic usage
#   powercli::vcenter::dvs_portgroup { 'vlan_10_portgroup_name':
#     dvswitch => 'dvswitch0',
#     vlan     => 10
#   }
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

