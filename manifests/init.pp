class batman () inherits batman::params {

  class { 'batman::install': } ->
  class { 'batman::config': }

  contain batman::install
  contain batman::config

  create_resources('batman::interface', hiera('batman::interface', {}))

}
