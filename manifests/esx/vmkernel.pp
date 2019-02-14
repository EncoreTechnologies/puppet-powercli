# @summary Resource that manages ESX DNS via PowerCLI
define powercli::esx::vmkernel (
  $server_data,
  $defaults,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  # Selecting the current ESX hosts data (to look for overrides)
  $current_server_data = $server_data[$name]['vmkernels']

  # $Use will be the function of the VMKernel. I.E. management, vmotion, iscsi_a, and iscsi_b.
  $current_server_data.each | $use, $data | {

    # takes the current VMK for the current host, and check if override settings are present for:
    # vSwitch, PortGroup, SubnetMask, or MTU. Overrides are placed directly under host in hiera.
    $vmk = merge($defaults[$use], $data)
    $ip = $vmk['ip']
    $pg = $vmk['portgroup']
    $vs = $vmk['switch']
    $mtu = $vmk['mtu']
    $subnet = $vmk['subnet']

    # Grabbing the vmotion vmkernel (so we can enable vmotion on it)
    $_new_cmd = "New-VMHostNetworkAdapter -VMHost ${name} -VirtualSwitch ${vs} -Mtu ${mtu} -PortGroup ${pg} -IP ${ip} -SubnetMask ${subnet}"

    if $use == 'vmotion' {
      exec { "${name}: Create ${use} vmkernel ${ip} ":
        command  => "${_connect}; ${_new_cmd} -VMotionEnabled \$true",
        provider => 'powershell',
        onlyif   => template('powercli/powercli_esx_vmkernel_onlyif.ps1.erb'),
      }
    }
    # Filtering out the management VMKernel (exists by default - it's required to talk to the host)
    elsif ($use == 'iscsi_a') or ($use == 'iscsi_b')  {
      exec { "${name}: Create ${use} vmkernel ${ip} ":
        command  => "${_connect}; ${_new_cmd}",
        provider => 'powershell',
        onlyif   => template('powercli/powercli_esx_vmkernel_onlyif.ps1.erb'),
      }
    }
    # Catching the management use so we can continue / pass
    # Otherwise management VMK creates an error in the 'use' catch all check below
    elsif $use == 'management' {
      # Do nothing, continue the puppet run.
    }
    # Catching any unknown 'use' types that may be entered into hiera
    else{
      fail("VMKernel with unknown use: (${use}) defined under host ${name} detected."
            + " The known use types are: 'management', 'vmotion', 'iscsi_a', and 'iscsi_b'")
    }
  }
}
