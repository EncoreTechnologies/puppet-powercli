<<<<<<< HEAD
# Class that manages DvSwitch Portgroups
=======
# @summary Manages distributed virtual switch (dvswitch or dvs for short) portgroups.
#
# @param dvswitch
#   Name of the dvswitch we will add portgroups on.
# @param dvs_pgs
#   Hash of portgroup and VLAN IDs.
#
# @example Basic usage
#   powercli::vcenter::dvs_portgroups {'my-vcenter.fqdn.tld':
#     dvswitch => 'my_dvswitch_name_here',
#     $dvs_pgs => { 'vlan_10_portgroup_name_here' => 10, 'vlan_11_portgroup_name_here' => 11 }
#   }
>>>>>>> 47c4ffc... removed incorrect define keywords and added hosts into resource names
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
