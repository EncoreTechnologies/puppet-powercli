# @summary Resource that joins an ESX host to vCenter
#
# @param host_user
#   User account to login to the ESX host
# @param host_password
#   Password for the user to login to the ESX host
# @param host_location
#   Name of the VMware datacenter to join the host to
#
# @example Basic usage
#   powercli::esx::join_vcenter {'my-vmware-host.fqdn.tld':
#     host_user     => 'root'
#     host_password => 'this_should_be_encrypted'
#     host_location => 'my_vmware_datacenter_name'
#   }
define powercli::esx::join_vcenter (
  $host_user,
  $host_password,
  $host_location,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect
  $_cmd = "Add-VMHost -Name '${name}' -User '${host_user}' -Password '${host_password}' -Location '${host_location}' -Force"

  exec { "Join host to cluster - ${name}:":
    command  => "${_connect}; ${_cmd}",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_join_hosts_to_vcenter_onlyif.ps1.erb'),
  }
}
