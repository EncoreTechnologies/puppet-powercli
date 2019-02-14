# @summary Resource that manages an NFS datastore
define powercli::vcenter::nfs_datastore (
  $server,
  $nfs_name,
  $path
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  exec { "${name}: Create NFS datastore ${nfs_name}":
    command  => "${_connect}; New-Datastore -VMHost '${name}' -Nfs -Name '${nfs_name}' -Path '${path}' -NFSHost '${server}'",
    provider => 'powershell',
    onlyif   => template('powercli/powercli_esx_nfs_datastore_onlyif.ps1.erb'),
  }
}
