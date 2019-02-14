# Class that manages ESX vswitch management portgroup
define powercli::esx::mgmt_portgroup (
  $server_data,
  $defaults,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $current_server_vmkernels = $server_data[$name]['vmkernels']
  $current_server_vmkernels.each | $use, $data | {

    # takes the current VMK for the current host, and check if override settings are present for:
    # vSwitch or PortGroup. Overrides are placed directly under host at in hiera.
    $vmk = merge($defaults[$use], $data)
    $portgroup = $vmk['portgroup']
    $vswitch = $vmk['switch']

    if $use == 'management' {
      exec { "${name}: Set mgmt portgroup name":
        command  => template('powercli/powercli_esx_mgmt_portgroup.ps1.erb'),
        provider => 'powershell',
        onlyif   => template('powercli/powercli_esx_mgmt_portgroup_onlyif.ps1.erb'),
      }
    }
  }
}
