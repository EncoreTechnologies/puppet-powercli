# @summary Resource that manages ESX Syslog via PowerCLI
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

  powercli::esx_service {"${name} - syslog":
    service   => 'vmsyslogd',
    host      => $name,
    subscribe => Exec["${name} Set Syslog Servers"],
  }
}
