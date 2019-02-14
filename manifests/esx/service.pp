# @summary Resource that manages an ESX Service via PowerCLI
define powercli::esx::service (
  $service,
  $host,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $_get_service = "${_connect}; Get-VMHost -Name '${host}' | Get-VMHostService | Where-Object {\$_.Key -eq '${service}'}"

  # Note that setting a service to auto start does not start that service
  # The command should only run if the service was not set to start auto previously.
  exec { "${host}: Enable service ${service}":
    command  => "${_get_service} | Set-VMHostService -Policy 'automatic'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_service_enable_onlyif.ps1.erb'),
  }

  # Command should only run if the service was not currently running
  exec { "${host}: Start service ${service}":
    command  => "${_get_service} | Start-VMHostService",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_service_start_onlyif.ps1.erb'),
  }

  # Note that restarting a service will start a not currently running service
  exec { "${host}: Restart service ${service}":
    command     => "${_get_service} | Restart-VMHostService -confirm:\$false",
    provider    => 'powershell',
    refreshonly => true,
  }
}
