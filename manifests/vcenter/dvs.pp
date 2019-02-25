# Class that manages DvSwitch creation
# @summary Manages distributed virtual switch (dvswitch or dvs for short) creation.
#
# @param datacenter
#   Name of the VMWare datacenter you wish to create the dvs within.
# @param mtu
#   MTU size on on the dvs. If you will have VMKernels on this dvs with more than 1500 mtu
#   you will need to increase the mtu on the dvs accordingly.
# @param uplink_count
#   Number of physical uplinks the dvs expects on each ESX host.
# @param discovery_proto
#   Discovery protocol configured on the dvs. Accepted discovery protocols are;
#   - LLDP (Link Layer Discovery Protocol)
#   - CDP (Cisco Discovery Protocol)
# @param discovery_proto_operation
#   Link discovery protocol operation for the dvs. Accepted operations are;
#   - Advertise
#   - Listen
#   - Both
#   - Disabled
# @param dvswitch_name
#   Name of the dvs.
#
# @example Basic usage
#   powercli::vcenter::dvs {'my-vcenter.fqdn.tld':
#     datacenter                => 'my_datacenter_name_here',
#     mtu                       => '9000',
#     uplink_count              => '2',
#     discovery_proto           => 'LLDP',
#     discovery_proto_operation => 'Both',
#     dvswitch_name             => 'my_dvswitch_name_here'
#   }
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
