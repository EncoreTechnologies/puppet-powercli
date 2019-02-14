# Class that manages ESX parameters for powercli
class powercli::vcenter::connection (
  String $server,
  String $username,
  String $password,
) {
  $connect = "Connect-VIServer -Server '${server}' -Username '${username}' -Password '${password}'"
}
