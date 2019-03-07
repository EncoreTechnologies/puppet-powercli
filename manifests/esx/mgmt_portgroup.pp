# @summary Resource that manages ESX vswitch management portgroup name
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
#
# @example Basic usage
#   powercli::esx::mgmt_portgroup { 'my-vmware-host.fqdn.tld':
#     server_data => {
#       my-vmware-host01.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.10
#           },
#           vmotion    => {
#             ip => 192.168.3.10
#           },
#           iscsi_a    => {
#             ip => 192.168.10.10
#           },
#           iscsi_b    => {
#             ip => 192.168.11.10
#           },
#         },
#       },
#       my-vmware-host02.fqdn.tld => {
#         vmkernels => {
#           management => {
#             ip => 192.168.2.11
#           },
#           vmotion    => {
#             ip => 192.168.3.11
#           },
#           iscsi_a    => {
#             ip => 192.168.10.11
#           },
#           iscsi_b    => {
#             ip => 192.168.11.11
#           },
#         },
#       },
#     }
#     defaults => {
#       management: {
#         portgroup => 'management-portgroup-name',
#         subnet    => 255.255.255.0,
#         mtu       => 9000,
#         switch    => 'name-of-dvswitch-management-portgroup-lives-on'
#       },
#     },
#   }
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
