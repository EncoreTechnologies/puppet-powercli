# Class that manages DvSwitch creation
define powercli::vcenter::dvs (
  $datacenter,
  $mtu,
  $uplink_count,
  $discovery_proto,
  $discovery_proto_operation,
  $dvswitch_name,
) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $_cmd = "New-VDSwitch -Name '${dvswitch_name}' -Location ${datacenter}' -Mtu ${mtu} \
            -Numuplinkports ${uplink_count} \
            -LinkDiscoveryProtocol ${discovery_proto} \
            -LinkDiscoveryProtocolOperation ${discovery_proto_operation}"

  exec { "Create dvswitch: ${dvswitch_name}":
    command  => "${_connect}; ${_cmd}",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dvs_switch_onlyif.ps1.erb'),
  }
}
