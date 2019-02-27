# @summary Resource that manages ESX iSCSI targets
#
# @param array_info
#   Hash of array info that contains;
#   - iSCSI Target IP address
#   - discovery type of target (static or dynamic) this is determined by the vendor of the target.
#   - The IQN of the target. Example: iqn.2010-06.com.storagevendor:arraytype.xxxxxxxxxxxxx
#   - Chap username (if required for the target)
#   - Chap password (if required for the target)
# @param defaults
#   Hash of default values used to configure iSCSI which contains;
#   - iSCSI target port (3260)
#
# @example Basic usage
#   powercli::esx::iscsi_targets {'my-vmware-host.fqdn.tld':
#     array_info => {
#       my-san01_target01 => {
#         discovery => 'static',
#         iscsi_name => 'iqn.2010-06.com.storagevendor:arraytype.xxxxxxxxxxxxx',
#         targets => ['192.168.1.100','192.168.1.101','192.168.1.102','192.168.1.103']}
#       my-san02_target01 => {
#         discovery => 'dynamic',
#         iscsi_name => 'iqn.2010-06.com.diffstoragevendor:arraytype.yyyyyyyyyyyyy',
#         targets => ['192.168.1.200','192.168.1.201','192.168.1.202','192.168.1.203']}}
#       defaults => {
#         port => '3260' }
define powercli::esx::iscsi_targets (
  $array_info,
  $defaults,
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  $default_port = $defaults['port']

  $array_info.each | $array, $data | {
    $targets = $data['targets']
    $chap_user = $data['chap_user']
    $chap_pass = $data['chap_pass']
    $discovery = $data['discovery']
    $iscsi_name = $data['iscsi_name']

    # Identifying if we are using CHAP
    $chap_str = $chap_user ? {
      undef => 'without chap',
      default => 'with chap'
    }


    # Filtering out any target without a discovery type OR a discovery type different than known types
    if ($discovery == 'dynamic') or ($discovery == 'static') {
      $targets.each | $target | {
        exec { "${name}: Add ${array} iSCSI target: ${target} ${chap_str} with ${discovery} discovery":
          command  => template('powercli/powercli_esx_iscsi_targets.ps1.erb'),
          provider => 'powershell',
          onlyif   => template('powercli/powercli_esx_iscsi_targets_onlyif.ps1.erb'),
          # Tag this resource so we can reference later for rescans
          tag      => "powercli::esx::iscsi_targets_${name}",
        }
      }
    }
    else{
      fail("iSCSI Array: ${array} has discovery type of: (${discovery})."
            + 'This does not match known discovery types. '
            + "Known discovery types are: 'static' or 'dynamic'.")
    }
  }

  # Calls the rescan resource but it does not run because the exec within the rescan resource is `refreshonly`
  powercli::esx::iscsi_rescan { $name: }

  # Aggregates all change events of iSCSI targets being added to the hosts,
  # if any targets were added to a host, that host will be rescanned a single time.
  Exec<| tag == "powercli::esx::iscsi_targets_${name}" |>
  ~> Powercli::Esx::Iscsi_rescan[$name]
}
