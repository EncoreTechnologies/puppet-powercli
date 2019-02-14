# @summary Resource that applies licenses to vcenter
define powercli::vcenter::license (
  $key,
) {

  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "License vCenter - ${name}":
    command  => template('powercli/powercli_esx_license_vcenter.ps1.erb'),
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_license_vcenter_onlyif.ps1.erb'),
  }
}
