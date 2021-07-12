require File.expand_path(File.join(File.dirname(__FILE__), '..', 'powercli'))
require 'uri'

Puppet::Type.type(:powercli_esx_syslog).provide(:api, parent: Puppet::Provider::PowerCLI) do
  commands powershell: 'powershell.exe'

  # always need to define this in our implementation classes
  mk_resource_methods

  # global cached instances across all resource instances
  def all_instances
    Puppet.debug("all_instances - cached instances is: #{cached_instances}")
    Puppet.debug("all_instances - cached instances object id: #{cached_instances.object_id}")
    # return cache if it has been created, this means that this function will only need
    # to be loaded once, returning all instances that exist of this resource in vsphere
    # then, we can lookup our version by name/id/whatever. This saves a TON of processing
    return cached_instances unless cached_instances.nil?

    cmd = <<-EOF
      $syslog_servers_hash = @{}
      $hosts = #{powercli_get_online_hosts}
      foreach($h in $hosts) {
        $servers = Get-VMHostSysLogServer -VMHost $h
        if ($servers){
          $syslog_servers_hash[$h.Name] = @($servers)
        } else {
            $syslog_servers_hash[$h.Name] = @()
        }
      }
      $syslog_servers_hash | ConvertTo-Json
      EOF

    syslog_servers_stdout = powercli_connect_exec(cmd)[:stdout]

    cached_instances_set({})

    unless syslog_servers_stdout.empty?
      syslog_servers_hash = JSON.parse(syslog_servers_stdout)
      cached_instances_set({})
      syslog_servers_hash.each do |esx_host, syslog_server_info_array|
        # Because the syslog_server_info_array has multiple elements (Host and Port)
        # It will return as an array.
        syslog_server_info = syslog_server_info_array[0]
        # Example url: udp://192.168.1.10
        uri = URI(syslog_server_info['Host'])
        cached_instances[esx_host] = {
          ensure: :present,
          esx_host: esx_host,
          syslog_server: uri.host,
          syslog_protocol: uri.scheme,
          syslog_port: syslog_server_info['Port'],
        }
      end
    end
    cached_instances
  end

  def read_instance
    if all_instances.key?(resource[:esx_host])
      all_instances[resource[:esx_host]]
    else
      {
        ensure: :absent,
        esx_host: resource[:esx_host],
      }
    end
  end

  # this flush method is called once at the end of the resource run
  def flush_instance
    # if we are adding our changing our syslog servers
    return unless resource[:ensure] == :present
    cmd = <<-EOF
    # Example $syslog: "udp://192.168.1.10:514"
    $syslog = '#{resource[:syslog_protocol]}://#{resource[:syslog_server]}:#{resource[:syslog_port]}'
    Set-VMHostSysLogServer -VMHost '#{resource[:esx_host]}' -SysLogServer $syslog
    EOF
    output = powercli_connect_exec(cmd)
    raise "Error when executing command #{cmd}\n stdout = #{output[:stdout]} \n stderr = #{output[:stderr]}" unless output[:exitcode].zero?
  end
end
