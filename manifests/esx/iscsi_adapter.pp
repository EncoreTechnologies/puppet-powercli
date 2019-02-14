# Class that manages ESX iSCSI software adapter
define powercli::esx::iscsi_adapter (
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "${name}: Enable iSCSI adapter":
    command  => "${_connect}; Get-VMHost -Name '${name}' | Get-VMHostStorage | Set-VMHostStorage -SoftwareIScsiEnabled \$true",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_iscsi_adapter_onlyif.ps1.erb'),
  }
}
