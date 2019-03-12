define powercli::esx::iscsi_target (
  $discovery,
  $iscsi_name,
  $targets,
  $chap_user,
  $chap_pass,
  $port
) {
  include powercli::vcenter::connection
  $_connect = $powercli::vcenter::connection::connect

  # Filtering out any target without a discovery type OR a discovery type different than known types
  if ($discovery == 'dynamic') or ($discovery == 'static') {
    $targets.each | $target | {
        exec { "${name}: Add ${array} iSCSI target: ${target} ${chap_str} with ${discovery} discovery":
        command  => #template('powercli/powercli_esx_iscsi_targets.ps1.erb'),
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


  # # Calls the rescan resource but it does not run because the exec within the rescan resource is `refreshonly`
  # powercli::esx::iscsi_rescan { $name: }

  # # Aggregates all change events of iSCSI targets being added to the hosts,
  # # if any targets were added to a host, that host will be rescanned a single time.
  # Exec<| tag == "powercli::esx::iscsi_targets_${name}" |>
  # ~> Powercli::Esx::Iscsi_rescan[$name]
}
