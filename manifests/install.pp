class batman::install inherits batman {

  include apt

  if(!defined(Package['apt-transport-https'])) {
    package { 'apt-transport-https':
      ensure => installed,
    }
  }

  apt::source { 'ffnw':
    location => 'http://repo.ffnw.de',
    release  => 'jessie',
    repos    => 'main',
    key      => {
      'id'     => 'BC8D3582BAB747C41B543B418B25EEE8C7A14712',
      'server' => 'pgpkeys.mit.edu',
    },
  }

  package {
    'batman-adv-dkms':
      ensure => 'installed';
    'batctl':
      ensure => 'installed';
  }

}
