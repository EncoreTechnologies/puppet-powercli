# @summary Resource that manages ESX DvSwitch Host membership
#
# @param esx_host
#   Name or IP address of the ESX host you would like joined to the dvswitch.
# @param dvswitch_name
#   Name of the dvs.
# @param dvswitch_nic_defaults
#   Hash of physical NIC layout defaults. Generally your 'defaults' will be your most common hardware
#   model.
#   Example: Assume you have the following;
#     - 10 ESX hosts where vmnic0 & 1 are 10GB adapters and vmnic2 & 3 are 1GB adapters
#     - 1 ESX host where vmnic2 & 3 are 10GB and vmnic0 & 1 are 1GB (opposite of above)
#   You would set dvswitch_nic_defaults to vmnic0 & 1 for distributed vswitch, and
#   vmnic2 & 3 are for standard vswitch. It would look like:
#   dvswitch_nic_defaults => { 'nics' => [ 'vmnic0', 'vmnic1'] }
# @param overrides
#   Hash of physical NIC overrides for ESX hosts that do not match your dvswitch_nic_defaults. In
#   the example above, overrides would be used for the host that is unlike the rest. 
#   Assuming your defaults looked like;
#   dvswitch_nic_defaults => { 'nics' => [ 'vmnic0', 'vmnic1'] }
#   your overrides for the host that do not match the others would look like;
#   overrides => { 'nics' => [ 'vmnic2', 'vmnic3'] }
#
# @example Basic usage - Using Default NICs on host. This will attach vmnic0 & 1 to the dvs.
#   powercli::esx::dvs_add_hosts {'my-vmware-host.fqdn.tld':
#     esx_host      => 'my_esx_hostname_or_ip_here',
#     dvswitch_name => 'my_dvswitch_name_here',
#     dvswitch_nic_defaults => {
#     'my_dvswitch_name_here' => {
#       'type' => distributed,
#       'nics' => [ 'vmnic0', 'vmnic1']},
#     'my_svswitch_name_here' => {
#       'type' => standard,
#       'nics' => [ 'vmnic2', 'vmnic3']}
#     },
#   }
# @example Override usage - Using Override NICs on host. This will attach vmnic2 & 3 to the dvs.
#   powercli::esx::dvs_add_hosts {'my-special-vmware-host.fqdn.tld':
#     esx_host      => 'my_esx_hostname_or_ip_here',
#     dvswitch_name => 'my_dvswitch_name_here',
#     dvswitch_nic_defaults => {
#     'my_dvswitch_name_here' => {
#       'type' => distributed,
#       'nics' => [ 'vmnic0', 'vmnic1']},
#     'my_svswitch_name_here' => {
#       'type' => standard,
#       'nics' => [ 'vmnic2', 'vmnic3']}
#     }
#     overrides => {
#     'my_dvswitch_name_here' => {
#       'type' => distributed,
#       'nics' => [ 'vmnic2', 'vmnic3']},
#     'my_svswitch_name_here' => {
#       'type' => standard,
#       'nics' => [ 'vmnic0', 'vmnic1']}
#     }
#   }
define powercli::esx::dvs_add_hosts (
  $esx_host,
  $dvswitch_name,
  $nics,
  ) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  # For each phyysical nic to be added to the dvswitch..
  $nics.each | $nic | {
    # Add the current $nic
    # exec { "${name}: add ${nic} to ${dvswitch_name}":
    #   command  => template('powercli/powercli_esx_dvs_add_hosts.ps1.erb'),
    #   provider => 'powershell',
    #   onlyif   => template('powercli/powercli_esx_dvs_add_hosts_onlyif.ps1.erb'),
    # }
    $onlyif = template('powercli/powercli_esx_dvs_add_hosts_onlyif.ps1.erb')
    notify{ "host ${esx_host} needs ${nic} connected on ${dvswitch_name}" : }
    notify{ "${esx_host} - ${nic} test is: ${test}" : }
  }
}
