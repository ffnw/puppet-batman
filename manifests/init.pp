class batman (
  
) inherits batman::params {

  contain '::batman::install'
  contain '::batman::config'

  class { 'batman::install': } ->
  class { 'batman::config': }

  create_resources('batman::interface', hiera('batman::interface', {}))

}
