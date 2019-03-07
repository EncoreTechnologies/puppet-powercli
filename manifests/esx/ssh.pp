# @summary Resource that manages ESX SSH via PowerCLI
#
# @example Basic usage
# powercli::esx::ssh { 'my-vmware-host.fqdn.tld': }
define powercli::esx::ssh (
) {
  powercli::esx::service {"${name} - ssh":
    service => 'TSM-SSH',
    host    => $name,
  }
}
