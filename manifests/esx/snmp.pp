# @summary Resource that manages ESX SNMP via powercli
define powercli::esx::snmp (
  $username,
  $password,
  $community,
  $port,
  $targets,
) {
  $targets.each | $target | {
    exec { "${name} Set SNMP target ${target}":
      command  => template('powercli/powercli_esx_snmp.ps1.erb'),
      provider => 'powershell',
      onlyif   => template('powercli/powercli_esx_snmp_onlyif.ps1.erb'),
    }
    powercli::esx::service {"${name} - snmpd":
      service   => 'snmpd',
      host      => $name,
      subscribe => Exec["${name} Set SNMP target ${target}"],
    }
  }
}
