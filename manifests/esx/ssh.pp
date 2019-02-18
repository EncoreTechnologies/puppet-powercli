# @summary Resource that manages ESX SSH via PowerCLI
define powercli::esx::ssh (
) {
  powercli::esx::service {"${name} - ssh":
    service => 'TSM-SSH',
    host    => $name,
  }
}
