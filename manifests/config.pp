# @summary Resource that manages a PowerCLI config item.
#
# @see https://code.vmware.com/docs/7634/cmdlet-reference#/doc/Set-PowerCLIConfiguration.html
#
# @param name
#   Name of the PowerCLI config parameter, defaults to $title
#
# @param value
#   The value of our config parameter for PowerCLI. Use native Puppet types here (boolean, string)
#   and this resource will try to do an intelligent conversion to the PowerShell types for you.
#   If all else fails, then fall back and just use a string with the value you want to set.
#
# @param scope
#   The scope where the configuration setting should be applied:
#
# @example Disable participating in the customer experience program
#    powercli::config { 'ParticipateInCEIP':
#      value => false,
#    }
#
# @example Disable SSL certificate validation when using PowerCLI
#   powercli::config { 'InvalidCertificateAction':
#     value => 'Ignore',
#   }
define powercli::config (
  Variant $value,
  String $scope = 'AllUsers',
) {
  # because powershell is jacked up and doesn't have the same representation for
  # booleans and their string types... need to do some magic conversion
  $_ps_value = $value ? {
    Boolean => bool2str($value, "\$true", "\$false"),
    default => $value,
  }
  $_ps_value_test = $value ? {
    Boolean => bool2str($value, 'True', 'False'),
    default => $value,
  }

  exec { "Set-PowerCLIConfiguration ${name}":
    command   => "Set-PowerCLIConfiguration -Scope ${scope} -${name} ${_ps_value} -confirm:\$false",
    onlyif    => "if (((Get-PowerCLIConfiguration -Scope ${scope}).${name} -as [string]) -ne '${_ps_value_test}') {exit 0} else {exit 1}",
    logoutput => true,
    provider  => powershell,
  }
}
