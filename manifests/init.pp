# @summary Class that installs PowerCLI via PowerShell Gallery on a Windows host.
#   Requires PowerShell 5 (default on Windows 2016) or PowerShellCore 6.
#
# @param config
#   Hash of config settings for PowerCLI that will be used to create new powercli::config
#   instances using create_resources
#
# @example Basic usage
#   # install PowerCLI from PowerShell Gallery
#   include powercli
#
# @example Specify vCenter connection settings globally
#   class { 'powercli':
#     vcenter_connection => {
#       'server' => 'vcenter.domain.tld',
#       'username' => 'user@domain.tld',
#       'password' => 'xyz123!',
#     }
#   }
#
# @example Override config settings
#   # install PowerCLI from PowerShell Gallery
#   class { 'powercli':
#     config => {
#       'ParticipateInCEIP' => {
#         value => true,
#       },
#     }
#   }
#
class powercli (
  Optional[Powercli::Connection] $vcenter_connection = undef,
  Optional[Hash]                 $config             = $powercli::params::config,
) inherits powercli::params {
  pspackageprovider { 'Nuget':
    ensure => 'present',
  }

  psrepository { 'PSGallery':
    ensure              => present,
    source_location     => 'https://www.powershellgallery.com/api/v2',
    installation_policy => 'trusted',
  }

  package { 'VMware.PowerCLI':
    ensure   => latest,
    provider => 'windowspowershell',
    source   => 'PSGallery',
  }

  if $config != undef {
    create_resources('powercli::config', $config)
  }

  if $vcenter_connection != undef {
    class { 'powercli::vcenter::connection':
      server   => $vcenter_connection['server'],
      username => $vcenter_connection['username'],
      password => $vcenter_connection['password'],
    }
    contain powercli::vcenter::connection
  }
}
