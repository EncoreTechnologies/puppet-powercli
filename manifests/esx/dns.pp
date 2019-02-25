# @summary Resource that manages ESX hosts; hostname, DNS servers, DNS domain, and DNS search domain
#
# @param dns_servers
#   List of DNS servers that the ESX will use as name servers
# @param domain
#   DNS domain suffix which will be the search domain and DNS domain. Example: foo.domain.com
#
# @example Basic usage
#   powercli::esx::dns {'my-vmware-host.fqdn.tld':
#     dns_servers => '192.168.1.10', '192.168.1.11',
#     domain => 'foo.domain.com'
#   }
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
