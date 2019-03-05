# @summary Resource that manages ESX Syslog via PowerCLI
#
# @param syslog_server
#   syslog server FQDN or IP address
# @param syslog_port
#   Port to be used when communicating with the syslog server
# @param syslog_protocol
#   TCP or UDP protocol to be used when communicating with syslog server
#
# @example Basic usage
#   powercli::esx::syslog {'my-vmware-host.fqdn.tld':
#     syslog_server   => 192.168.1.10,
#     syslog_port     => 514,
#     syslog_protocol => udp
#   }
define powercli::esx::syslog (
  $syslog_server,
  $syslog_port,
  $syslog_protocol,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $syslog = "${syslog_protocol}://${syslog_server}:${syslog_port}"
  exec { "${name} Set Syslog Servers":
    command  => "${_connect}; Set-VMHostSysLogServer -VMHost '${name}' -SysLogServer '${syslog}'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_syslog_onlyif.ps1.erb'),
  }

  powercli::esx::service {"${name} - syslog":
    service   => 'vmsyslogd',
    host      => $name,
    subscribe => Exec["${name} Set Syslog Servers"],
  }
}
