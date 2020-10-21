require File.expand_path(File.join(File.dirname(__FILE__), '..', 'powercli'))
require 'ruby-pwsh'

Puppet::Type.type(:powercli_esx_ntp).provide(:api, parent: Puppet::Provider::PowerCLI) do

  # always need to define this in our implementation classes
  mk_resource_methods
  
  commands :powershell => 'powershell.exe'
  
  def self.get_instances(vcenter, username, password)
    return @@instances unless @@instance.nil?
    # Want to return an array of instances
    #  each hash should have the same properties as the properties
    #  of this "type"
    #  remember the keys should be symbols, aka :ntp_servers not 'ntp_servers'
    # This is a tracking hash which will contain info about each host and NTP server relationships
    cmd = <<-EOF
Connect-VIServer -Server '#{vcenter}' -Username '#{username}' -Password '#{password}'
$ntp_servers_hash = @{}
$hosts = Get-VMHost
foreach($h in $hosts) {
  $servers = Get-VMHostNtpServer -VMHost $h
  if ($servers) {
     $ntp_servers_hash[$h.Name] = @($servers)
  } else {
     $ntp_servers_hash[$h.Name] = @()
  }
}
$ntp_servers_hash | ConvertTo-Json
    EOF
    
    ntpservers_stdout = ps(cmd)[:stdout]
    # json parse expects a json string, powershell does not stdout with quotes
    # we might be able to remove this line because powershell exits with a viable ruby array already:
    # [
    #   "time1.dev.encore.tech",
    #   "time2.dev.encore.tech"
    # ]
    # what happens if this returns null??
    ntpservers_hash = JSON.parse(ntpservers_stdout)
    
    # create instance hash - this contains info about ONE host at a time
    # the values should match the data "shape" (ie have the same fields) as our
    # type.
    # the key, should be the title/namevar so we can do a lookup in our
    # read_instance function
    @@instances = {}
    ntpservers_hash.each do |esx_host, ntp_servers|
      @@instances[esx_host] = {
        esx_host: esx_host,
        ntp_servers: ntpservers_array,
        ensure: :present,
      }
    end
    @@instances
  end

  def read_instance
    instances = self.get_instances(resource[:vcenter],
                                   resource[:username],
                                   resource[:password])
    if instances.key?(resource[:esx_host])
      instances[resource[:esx_host]]
    else
      {
        ensure: :absent,
        esx_host: resource[:esx_host],
      }
    end
  end

  # this flush method is called once at the end of the resource
  # and we're going to do our bulk write in here
  def flush_instance
    # delete all of the existing ones by default
    cmd = <<-EOF
# The old / original NTP servers
$OriginalNTPServers = Get-VMHostNtpServer -VMHost '#{resource[:esx_host]}'

# Remove old NTP servers
Remove-VMHostNtpServer -VMHost '#{resource[:esx_host]}' -NtpServer $OriginalNTPServers -confirm:$false
    EOF

    # if we are adding our changing our servers, just add them here
    if resource[:ensure] == :present
      cmd += <<-EOF
# Set the NTP servers we want
Get-VMHost -name '#{resource[:esx_host]}' | Add-VMHostNtpServer -NtpServer #{resource[:ntp_servers].join(', ')}
    EOF
    end

    Puppet.debug("Executing powershell: #{connect_cmd + cmd}")
    
    output = ps(connect_cmd + cmd)
    if output[:exitcode] != 0
      raise "Error when executing command #{cmd}\n stdout = #{output[:stdout]} \n stderr = #{output[:stderr]}"
    end
  end
end
