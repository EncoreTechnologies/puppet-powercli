# Class that manages storage HBA rescans on ESX hosts
define powercli::esx::iscsi_rescan (
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "${name} Rescan HBAs":
    command     => "${_connect}; Get-VMHostStorage -RescanAllHba -VMHost ${name}",
    provider    => 'powershell',
    refreshonly => true,
  }
}
