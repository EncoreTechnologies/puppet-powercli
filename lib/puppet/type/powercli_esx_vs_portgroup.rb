Puppet::Type.newtype(:powercli_esx_vs_portgroup) do
  desc 'This type provides Puppet with the capabilities to manage portgroups on standard vswitches on an esx host'

  ensurable

  newparam(:esx_host, namevar: true) do
    desc 'The name of the esx host in which the standard vswitch will be managed on'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "esx_host is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newproperty(:vswitch_name) do
    desc 'Name of the vswitch which will be used on the esx_host'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "vswitch_name is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newproperty(:vlan) do
    desc 'VLAN ID to be assigned to the portgroup'
    validate do |value|
      unless value.is_a?(Integer)
        raise ArgumentError, "vlan is expected to be a Integer, given: #{value.class.name}"
      end
    end
  end

  newproperty(:portgroup) do
    desc 'Name of the portgroup which will be managed on the esx_host'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "portgroup is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  ################################
  newparam(:vcenter_connection) do
    desc <<-EOF
      The vcenter connection information. This should be a hash containing the following keys:
        - server : the hostname / ip of the server
        - username : the username to authenticate with vcenter
        - password : the password for the user when authenitcating

      Each of these keys should be a string
    EOF

    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, "vcenter_connection is expected to be a Hash, given: #{value.class.name}"
      end

      ['server', 'username', 'password'].each do |key|
        unless value.key?(key)
          raise ArgumentError, "vcenter_connection is missing key '#{key}'"
        end
        unless value[key].is_a?(String)
          raise ArgumentError, "vcenter_connection['#{key}'] is expected to be a String, given: #{value[key].class.name}"
        end
      end
    end
  end
end
