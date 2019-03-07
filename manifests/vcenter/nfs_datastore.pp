# @summary Resource that manages an NFS datastore
#
# @param server
#   FQDN or IP address of NFS server to be mounted
# @param nfs_name
#   Name to assign this NFS datastore
# @param path
#   Path to be mounted on the NFS server
#
# @example Basic Usage
#   powercli::vcenter::nfs_datastore {'my-vmware-host.fqdn.tld':
#     server   => '192.168.1.10',
#     nfs_name => 'my_nfs_datastore_name',
#     path     => '/srv/nfs/my_nfs_datastore'
#   }
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
