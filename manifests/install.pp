class batman::install inherits batman {

  include apt

  apt::source { 'ffnw':
    location => 'http://repo.ffnw.de',
    release  => 'jessie',
    repos    => 'main',
    key      => {
      'id'     => '8B25EEE8C7A14712',
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
