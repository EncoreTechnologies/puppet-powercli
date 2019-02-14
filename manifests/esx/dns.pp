# Class that manages ESX DNS via PowerCLI
define powercli::esx::dns (
  $dns_servers,
  $domain,
  ) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $_dns_servers = join($dns_servers, ', ')
  $name_split = split($name, '[.]')
  $hostname = $name_split[0]

  exec { "${name} - Set ESX DNS servers":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Get-VMHostNetwork | Set-VMHostNetwork -DnsAddress ${_dns_servers}",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dns_dnsservers_onlyif.ps1.erb'),
  }

  exec { "${name} - Set DNS hostname":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Get-VMHostNetwork | Set-VMHostNetwork -Hostname '${hostname}'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dns_hostname_onlyif.ps1.erb'),
  }

  exec { "${name} - Set DNS domain":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Get-VMHostNetwork | Set-VMHostNetwork -DomainName '${domain}'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dns_domain_onlyif.ps1.erb'),
  }

  exec { "${name} - Set DNS search domain":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Get-VMHostNetwork | Set-VMHostNetwork -SearchDomain '${domain}'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_dns_searchdomain_onlyif.ps1.erb'),
  }
}
