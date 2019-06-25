# @summary Resource that applies licenses to ESX an host
#
# @param key
#   The license key for the ESX host(s)
#
# @example Basic usage
#   powercli::esx::license {'my-vmware-host.fqdn.tld':
#     key => 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
#   }
define powercli::esx::license (
  $key,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "License host - ${name}:":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Set-VMHost -LicenseKey ${key}",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_license_hosts_onlyif.ps1.erb'),
  }
}
