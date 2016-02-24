class batman (
  
) inherits batman::params {

  require batman::install
  require batman::config

  create_resources('batman::interface', hiera('batman::interface', {}))

}
