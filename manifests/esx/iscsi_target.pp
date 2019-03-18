# @summary Resource that manages ESX iSCSI targets
#
# @param hostname
#   Hostname of the ESX host we are checking / ensuring targets on
# @param discovery
#   - Currently accepted discovery types are 'static' and 'dynamic'
#   - Discovery type of the array that holds the targets.
#     Determined by array manufacturer.
# @param targets
#   Array of iscsi target IP addresses
# @param port
#   TCP/IP port of the iscsi target (default 3260)
# @param iscsi_name
#   Required for targets that have discovery type of 'static'.
#   iSCSI IQN of the target. Example: iqn.2010-06.com.storagevendor:arraytype.xxxxxxxxxxxxx
# @param chap_user
#   Optional CHAP Parameter - Chap Username for target
# @param chap_pass
#   Optional CHAP Parameter - Chap Password for target
# @param san_name
#   Optional Parameter. Name of SAN that has targets added.
#
# @example dynamic target, with chap example:
# powercli::esx::iscsi_target { :
#   hostname => 'my-vmware-host.fqdn.tld',
#   discovery => 'dynamic',
#   targets => ['192.168.1.100', '192.168.1.101']
#   port => 3260
#   chap_user => 'my_chap_username'
#   chap_pass => 'my_chap_password_should_be_encrypted'
#   san_name => 'mysan01.fqdn.tld'
# }
#
# @example static target, no chap example:
# powercli::esx::iscsi_target { :
#   hostname => 'my-vmware-host.fqdn.tld',
#   discovery => 'static',
#   targets => ['192.168.1.200', '192.168.1.201']
#   port => 3260
#   san_name => 'mysan01.fqdn.tld',
#   iscsi_name => 'iqn.2010-06.com.storagevendor:arraytype.xxxxxxxxxxxxx'  
# }
define powercli::esx::iscsi_target (
  $hostname,
  $discovery,
  $targets,
  $port,
  Optional[String] $chap_user = undef,
  Optional[String] $chap_pass = undef,
  Optional[String] $iscsi_name = undef,
  Optional[String] $san_name = undef
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect
  
  #Filtering out any target without a discovery type OR a discovery type different than known types
  if ($discovery == 'dynamic') or ($discovery == 'static') {
    $targets.each | $target | {
        exec { "${hostname} target: ${target}":
        command  => template('powercli/powercli_esx_iscsi_targets.ps1.erb'),
        provider => 'powershell',
        onlyif   => template('powercli/powercli_esx_iscsi_targets_onlyif.ps1.erb'),
        # Tag this resource so we can reference later for rescans
        tag      => "powercli::esx::iscsi_targets_${hostname}",
      }
    }
  }
  else{
    fail("iSCSI Array: ${san_name} has discovery type of: (${discovery})."
          + 'This does not match known discovery types. '
          + "Known discovery types are: 'static' or 'dynamic'.")
  }
}
