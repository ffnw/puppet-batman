class batman::config inherits batman {

  file_line { 'batman-adv':
    path => '/etc/modules',
    line => 'batman-adv',
  }

}
