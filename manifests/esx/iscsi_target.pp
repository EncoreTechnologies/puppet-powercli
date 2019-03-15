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
        tag      => "powercli::esx::iscsi_targets_${name}",
      }
    }
  }
  else{
    fail("iSCSI Array: ${san_name} has discovery type of: (${discovery})."
          + 'This does not match known discovery types. '
          + "Known discovery types are: 'static' or 'dynamic'.")
  }

  # Calls the rescan resource but it does not run because the exec within the rescan resource is `refreshonly`
  powercli::esx::iscsi_rescan { $name:
    hostname => $hostname
  }

  # Aggregates all change events of iSCSI targets being added to the hosts,
  # if any targets were added to a host, that host will be rescanned a single time.
  Exec<| tag == "powercli::esx::iscsi_targets_${name}" |>
  ~> Powercli::Esx::Iscsi_rescan[$name]
}
