# @summary Resource that manages ESX SSH via PowerCLI
define powercli::esx::ssh (
) {
  powercli::esx_service {"${name} - ssh":
    service => 'TSM-SSH',
    host    => $name,
  }
}
