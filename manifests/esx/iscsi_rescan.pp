# @summary Resource that manages storage HBA rescans
#
# @param hostname
#   Name of the host we wish to rescan on
# @example Basic usage
#   powercli::esx::iscsi_rescan {
#     hostname => 'my-vmware-host.fqdn.tld',
#   }
define powercli::esx::iscsi_rescan (
  $hostname,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "Rescan HBAs || Name: ${name}":
    command     => "${_connect}; Get-VMHostStorage -RescanAllHba -VMHost ${hostname}",
    provider    => 'powershell',
    refreshonly => true,
  }
}
