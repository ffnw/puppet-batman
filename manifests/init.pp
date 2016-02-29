class batman (
  Optional[Variant[Integer,String]] $kernel_table = $batman::params::kernel_table
) inherits batman::params {

  class { 'batman::install': } ->
  class { 'batman::config': }

  contain batman::install
  contain batman::config

  create_resources('batman::interface', hiera('batman::interface', {}))

}
