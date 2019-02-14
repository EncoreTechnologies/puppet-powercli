# @summary Default parameters
class powercli::params {
  $config = {
    'ParticipateInCEIP' => {
      value => false,
    },
    'InvalidCertificateAction' => {
      value => 'Ignore',
    },
  }
}
