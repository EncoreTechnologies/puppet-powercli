# @summary Resource that manages ESX SNMP via powercli
#
# @param username
#   User account to login to the ESX host
# @param password
#   Password for the user to login to the ESX host
# @param community
#   SNMP community name
# @param port
#   Port to be used when communitcating with the SNMP target
# @param targets
#   SNMP targets that traps will be sent to
#
# @example Basic usage
#   powercli::esx::snmp {'my-vmware-host.fqdn.tld':
#     username  => 'root',
#     password  => 'this_should_be_encrypted',
#     community => 'my_community_name_should_be_encrypted_too',
#     port      => 161,
#     targets   => ['192.168.1.10', '192.168.1.11']
#   }
define powercli::esx::snmp (
  $username,
  $password,
  $community,
  $port,
  $targets,
)
{
  # exec { "${name} Set SNMP targets ${targets}":
  #   command  => template('powercli/powercli_esx_snmp.ps1.erb'),
  #   provider => 'powershell',
  #   onlyif   => template('powercli/powercli_esx_snmp_onlyif.ps1.erb'),
  # }
  # powercli::esx::service {"${name} - snmpd":
  #   service   => 'snmpd',
  #   host      => $name,
  #   subscribe => Exec["${name} Set SNMP targets ${targets}"],
  # }

  $test = template('powercli/powercli_esx_snmp_onlyif.ps1.erb')

  notify {"TEST: ${test}" : }

}
