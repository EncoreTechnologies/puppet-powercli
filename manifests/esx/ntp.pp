# @summary Resource that manages ESX NTP via PowerCLI
#
# @param ntp_servers
#   A array of ntp servers to be used as time sources for the ESX host
#
# @example Basic usage
#   powercli::esx::ntp { 'my-vmware-host.fqdn.tld' :
#     ntp_servers => ['192.168.1.10', '192.168.1.11']
#   }
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
