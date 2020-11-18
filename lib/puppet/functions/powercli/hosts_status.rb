require 'rbvmomi'

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
    credentials = {
      host: connection['server'],
      user: connection['username'],
      password: connection['password'],
      insecure: true
    }
    vim = RbVmomi::VIM.connect(credentials)

    # recursive find/grep to find all ESX hosts
    # Type list: https://code.vmware.com/apis/196/vsphere
    query = {
      container: vim.rootFolder,
      type: ['HostSystem'],
      recursive: true
    }
    host_list = vim.serviceContent.viewManager.CreateContainerView(query).view
    results = {}
    host_list.map do |host|
      results[host.name] = host.runtime.connectionState
    end
    results
  end
end
