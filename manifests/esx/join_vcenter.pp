# @summary Resource that joins an ESX host to vCenter
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
