Puppet::Type.newtype(:powercli_esx_ntp) do
  desc 'This type provides Puppet with the capabilities to manage NTP servers on an esx host'

  ensurable

  newparam(:esx_host, namevar: true) do
    desc 'The name of the esx host the NTP servers will be managed on'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "esx_host is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newproperty(:ntp_servers, array_matching: :all) do
    desc 'The password to login to vcenter'

    validate do |value|
      # puppet, being puppet if it's an array, it passes each value of t he array into this
      # validate function, so we just need to check that each thing is a string
      value.each do |v|
        unless v.is_a?(String)
          raise ArgumentError, "each ntp_server is expected to be a String, given: #{v.class.name}"
        end
      end
    end
    
    def sort_array(a)
      if a.nil?
        []
      else
        a.sort
      end
    end

    def should
      sort_array(super)
    end

    def should=(values)
      super(sort_array(values))
    end

    def insync?(is)
      sort_array(is) == should
    end
  end

  ################################
  newparam(:vcenter) do
    desc 'The vcenter which manages the esx host the NTP servers will be managed on'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "vcenter is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newparam(:username) do
    desc 'The username to login to vcenter'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "Username is expected to be a String, given: #{value.class.name}"
      end
    end
  end

  newparam(:password) do
    desc 'The password to login to vcenter'
    validate do |value|
      unless value.is_a?(String)
        raise ArgumentError, "Password is expected to be a String, given: #{value.class.name}"
      end
    end
  end
end
