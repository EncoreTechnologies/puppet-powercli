require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'encore', 'powercli', 'helper'))

# Returns a hash of hosts along with their connection status
# Note: this uses PowerCLI under the hood, so it should be run as a deferred function
Puppet::Functions.create_function(:'powercli::hosts_status') do
  # @param hosts Explicit list of hosts to retrieve status for.
  #              If not specified all hosts that exist in the vCenter will be returned
  # @return Hash where the key is the ESXi hostname, the value is the connection status for
  #         that host, either 'online' or 'offline'.
  #         Hosts that have a connection status of 'Disconnected' or 'NotResponding' will be
  #         marked as 'offline', otherwise they will be returned as 'online'.
  dispatch :hosts_status do
    required_param 'Powercli::Connection', :connection
    optional_param 'Array[String]', :hosts
    return_type "Hash[String, Enum['online', 'offline']]"
  end

  def hosts_status(connection, hosts = nil)
    cmd = <<-EOF
      $hosts_list = Get-VMHost
      $results = @{}
      foreach ($host in $hosts_list) {
        $results[$host.Name] = $host.ConnectionState
      }
      $results | ConvertTo-Json
      EOF
    resp = PuppetX::PowerCLI::Helper.instance.powercli_connect_exec(connection, cmd)
    hosts_hash = JSON.parse(resp[:stdout])
    if hosts
      # only return the hosts that the user asked for
      hosts_hash.select { |k, _v| hosts.include?(k) }
    else
      hosts_hash
    end
  end
end
