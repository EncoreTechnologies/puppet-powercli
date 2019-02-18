# @summary Resource that manages ESX NTP via PowerCLI
define powercli::esx::ntp (
  $ntp_servers,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $_ntp_servers = join($ntp_servers, ', ')

  exec { "${name}: Set NTP Servers":
    command  => template('powercli/powercli_esx_ntp.ps1.erb'),
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_ntp_onlyif.ps1.erb'),
  }

  powercli::esx::service {"${name} - ntp":
    service   => 'ntpd',
    host      => $name,
    subscribe => Exec["${name}: Set NTP Servers"],
  }
}
