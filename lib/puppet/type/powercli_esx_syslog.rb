Puppet::Type.newtype(:powercli_esx_syslog) do
  desc 'This type provides Puppet with the capabilities to manage syslog servers on an esx host'

  ensurable

  newparam(:esx_host, namevar: true) do
    desc 'The name of the esx host the syslog servers will be managed on'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "esx_host is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newproperty(:syslog_server) do
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "each syslog_server is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newproperty(:syslog_port) do
    validate do |value|
      unless value.is_a?(Integer)
        raise ArgumentError, "each syslog_port is expected to be a Integer, given: #{value.class.name}"
      end
    end
  end

  newproperty(:syslog_protocol) do
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "syslog_protocol is expected to be a String, given: #{value.class.name}"
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
