# @summary Manages the connection details that resources in this module will use to connect
#          with vCenter.
#
# @param server
#   Hostname / IP address of the vCenter server
# @param username
#   Username to use for vCenter authentication
# @param password
#   Password to use for vCenter authentication
# @param insecure
#   Without this, powercli will be unable to connect to a vcenter without a valid cert.
#
# @example Basic usage
#   class { 'powercli::vcenter::connection':
#     server   => 'vcenter.domain.tld',
#     username => 'user@domain.tld',
#     password => 'PassWord!',
#     insecure => 'true',  
#   }
class powercli::vcenter::connection (
  String $server,
  String $username,
  String $password,
  Enum['true', 'false'] $insecure,
)
{

  if $insecure == 'true' {
    $connect = "Connect-VIServer -Server '${server}' -Username '${username}' -Password '${password}' -Force"
  }
  else{
    $connect = "Connect-VIServer -Server '${server}' -Username '${username}' -Password '${password}'"
  }
}
