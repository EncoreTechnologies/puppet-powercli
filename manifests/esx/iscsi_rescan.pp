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
