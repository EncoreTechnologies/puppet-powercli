require File.expand_path(File.join(File.dirname(__FILE__), '..', 'powercli'))
require 'ruby-pwsh'

Puppet::Type.type(:powercli_esx_vs_portgroup).provide(:api, parent: Puppet::Provider::PowerCLI) do
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

    # Fetch the current status of the portgroup
    cmd = <<-EOF
      $portgroup_hash = @{}
      $hosts = #{powercli_get_online_hosts}
      foreach($h in $hosts) {
        $pg = Get-VirtualSwitch -Host $h -Standard -Name #{vswitch_name} | Get-VirtualPortGroup -Name #{portgroup}
        $obj_hash = @{}
        $obj_hash.Add('portgroup', $pg.Name)
        $obj_hash.Add('vlan', $pg.VLanId)
        $obj_hash.Add('vswitch_name', $pg.VirtualSwitchName)
        if ($pg) {
           $portgroup_hash[$h.Name] = @($obj_hash)
        } else {
           $portgroup_hash[$h.Name] = @()
        }
      }
      $portgroup_hash | ConvertTo-Json
      EOF

    portgroups_stdout = powercli_connect_exec(cmd)[:stdout]

    portgroups_hash = JSON.parse(portgroups_stdout)

    # create instance hash - this contains info about ONE host at a time
    # the values should match the data "shape" (ie have the same fields) as our
    # type.
    # the key, should be the title/namevar so we can do a lookup in our
    # read_instance function
    Puppet.debug('all_instances - hopefully calling setter method')
    cached_instances_set({})
    portgroups_hash.each do |esx_host, portgroups_hash|
      cached_instances[esx_host] = {
        ensure: :present,
        esx_host: esx_host,
        vswitch_name: portgroups_hash['vswitch_name'],
        vlan: portgroups_hash['vlan'],
        portgroup: portgroups_hash['portgroup'],
      }
    end
    Puppet.debug("all_instances - cached instances is at end: #{cached_instances}")
    Puppet.debug("all_instances - cached instances object_id at end: #{cached_instances.object_id}")
    cached_instances
  end

  def read_instance
    if all_instances.key?(resource[:esx_host])
      instance = all_instances[resource[:esx_host]]
      instance[:title] = resource[:title]
      Puppet.debug("instance is: #{instance}")
      instance
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

    # if we are adding our changing our servers, just add them here
    if resource[:ensure] == :present
      cmd += <<-EOF
        # Create the portgroup we want on the vswitch we want it on
        Get-VirtualSwitch -VMHost '#{resource[:esx_host]}' -Name '#{resource[:vswitch_name]}' -Standard | New-VirtualPortgroup -Name '#{resource[:portgroup]}' -VLanID #{resource[:vlan]}
        EOF
    end

    output = powercli_connect_exec(cmd)
    raise "Error when executing command #{cmd}\n stdout = #{output[:stdout]} \n stderr = #{output[:stderr]}" unless output[:exitcode].zero?
  end
end
