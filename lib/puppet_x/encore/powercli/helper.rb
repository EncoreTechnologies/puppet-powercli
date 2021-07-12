require 'puppet_x'
require 'ruby-pwsh'
require 'singleton'

module PuppetX::PowerCLI
  # Helper class for Caching Instances
  class Helper
    include Singleton
    attr_accessor :cached_instances

    def initialize
      @cached_instances = {}
      @cached_ps = Pwsh::Manager.instance(Pwsh::Manager.powershell_path,
                                          Pwsh::Manager.powershell_args)
      @cached_powercli_sessions = {}
    end

    # Example usage:
    #   PuppetX::PowerCLI::Helper.ps(cmd)[:stdout]
    def ps(cmd)
      Puppet.debug("Running command: #{cmd}")
      # need to use [:stdout] from result
      @cached_ps.execute(cmd)
    end

    # connects to a PowerCLI session and returns the session ID
    def connect_session(vcenter_connection)
      if @cached_powercli_sessions.key?(vcenter_connection['server'])
        session_id = @cached_powercli_sessions[vcenter_connection['server']]
      else
        # our session is nil, so we need to conenct
        session_cmd = <<-EOF
          $session = Connect-VIServer -Server '#{vcenter_connection['server']}' -Username '#{vcenter_connection['username']}' -Password '#{vcenter_connection['password']}'
          $session.SessionId
          EOF
        resp = ps(session_cmd)
        Puppet.debug("connect session response = #{resp}")
        # remove quotes from the session id string, it returns us something in the format of:
        #  "abc123"
        # we strip because it returns us some new lines and white space in there as well
        session_id = resp[:stdout].delete('"').strip
        Puppet.debug("connect session parsed and stripped session id = #{session_id}")

        # save the session ID to our cache
        @cached_powercli_sessions[vcenter_connection['server']] = session_id
      end
      session_id
    end

    def connect_cmd(vcenter_connection)
      # cache our connection session ID and reuse it for all other resources
      session_id = connect_session(vcenter_connection)

      # connect with our session from above for from some other connection attempt :)
      <<-EOF
      Connect-VIServer -Server '#{vcenter_connection['server']}' -Session '#{session_id}' | Out-Null
      EOF
    end

    def powercli_connect_exec(vcenter_connection, cmd)
      ps(connect_cmd(vcenter_connection) + cmd)
    end
  end
end
