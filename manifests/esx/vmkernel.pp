# @summary Resource that manages ESX DNS via PowerCLI
#
# @param server_data
#   Hash of the ESX host which contains;
#   - list of VMKernel IPs for each host
#   - list of default overrides for each host
# @param defaults
#   Hash of defaults to be used when creating VMKernel IPs which contain;
#   - Portgroup the VMKernel will be created on
#   - vSwitch which contains the portgroup we will create the VMKernel on
#   - subnet mask of VMKenerl IP address
#   - MTU of VMKernel
# @example Basic usage
#   powercli::esx::vmkernel { 'my-vmware-host.fqdn.tld':
#     server_data => {
#       my-vmware-host01.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.10
#           },
#           vmotion => {
#             ip => 192.168.3.10
#           },
#           iscsi_a => {
#             ip => 192.168.10.10
#           },
#           iscsi_b => {
#             ip => 192.168.11.10
#           },
#         },
#       },
#       my-vmware-host02.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.11
#           },
#           vmotion => {
#             ip => 192.168.3.11
#           },
#           iscsi_a => {
#             ip => 192.168.10.11
#           },
#           iscsi_b => {
#             ip => 192.168.11.11
#           },
#         },
#       },
#     }
#     defaults => {
#       management: {
#         portgroup => 'management-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-management-portgroup-lives-on'
#       },
#       vmotion: {
#         portgroup => 'vmotion-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-vmotion-portgroup-lives-on'
#       },
#       iscsi_a: {
#         portgroup => 'iscsi_a-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_a-portgroup-lives-on'
#       },
#       iscsi_b: {
#         portgroup => 'iscsi_b-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_b-portgroup-lives-on'
#       },
#     },
#   }
#
# @example Full overrides; all settings for all VMKernel defaults for host 'my-vmware-host02.fqdn.tld' while maintaining defaults for host: 'my-vmware-host01.fqdn.tld'.
#   powercli::esx::vmkernel { 'my-vmware-host.fqdn.tld':
#     server_data => {
#       my-vmware-host01.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.10
#           },
#           vmotion => {
#             ip => 192.168.3.10
#           },
#           iscsi_a => {
#             ip => 192.168.10.10
#           },
#           iscsi_b => {
#             ip => 192.168.11.10
#           },
#         },
#       },
#       my-vmware-host02.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.11,
#             portgroup => 'snowflake_management_portgroup_name',
#             vswitch => 'snowflake_management_vswitch_name',
#             mtu => 1500,
#             subnet => 255.255.0.0
#           },
#           vmotion => {
#             ip => 192.168.3.11,
#             portgroup => 'snowflake_vmotion_portgroup_name',
#             vswitch => 'snowflake_vmotion_vswitch_name',
#             mtu => 1500,
#             subnet => 255.255.0.0
#           },
#           iscsi_a => {
#             ip => 192.168.10.11,
#             portgroup => 'snowflake_iscsi_a_portgroup_name',
#             vswitch => 'snowflake_iscsi_a_vswitch_name',
#             mtu => 1500,
#             subnet => 255.255.0.0          
#           },
#           iscsi_b => {
#             ip => 192.168.11.11,
#             portgroup => 'snowflake_iscsi_b_portgroup_name',
#             vswitch => 'snowflake_iscsi_b_vswitch_name',
#             mtu => 1500,
#             subnet => 255.255.0.0          
#           },
#         },
#       },
#     }
#     defaults => {
#       management: {
#         portgroup => 'management-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-management-portgroup-lives-on'
#       },
#       vmotion: {
#         portgroup => 'vmotion-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-vmotion-portgroup-lives-on'
#       },
#       iscsi_a: {
#         portgroup => 'iscsi_a-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_a-portgroup-lives-on'
#       },
#       iscsi_b: {
#         portgroup => 'iscsi_b-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_b-portgroup-lives-on'
#       },
#     },
#   }
# 
# @example Cherry picked overrides;  Only specific settings for each VMKernel override the defaults for host 'my-vmware-host02.fqdn.tld' while maintaining full defaults for host: 'my-vmware-host01.fqdn.tld'.
#   powercli::esx::vmkernel { 'my-vmware-host.fqdn.tld':
#     server_data => {
#       my-vmware-host01.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.10
#           },
#           vmotion => {
#             ip => 192.168.3.10
#           },
#           iscsi_a => {
#             ip => 192.168.10.10
#           },
#           iscsi_b => {
#             ip => 192.168.11.10
#           },
#         },
#       },
#       my-vmware-host02.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.11,
#             portgroup => 'snowflake_management_portgroup_name',
#           },
#           vmotion => {
#             ip => 192.168.3.11,
#             vswitch => 'snowflake_vmotion_vswitch_name',
#           },
#           iscsi_a => {
#             ip => 192.168.10.11,
#             mtu => 1500,
#           },
#           iscsi_b => {
#             ip => 192.168.11.11,
#             subnet => 255.255.0.0          
#           },
#         },
#       },
#     }
#     defaults => {
#       management: {
#         portgroup => 'management-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-management-portgroup-lives-on'
#       },
#       vmotion: {
#         portgroup => 'vmotion-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-vmotion-portgroup-lives-on'
#       },
#       iscsi_a: {
#         portgroup => 'iscsi_a-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_a-portgroup-lives-on'
#       },
#       iscsi_b: {
#         portgroup => 'iscsi_b-portgroup-name',
#         subnet => 255.255.255.0,
#         mtu => 9000,
#         switch => 'name-of-dvswitch-iscsi_b-portgroup-lives-on'
#       },
#     },
#   }
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
