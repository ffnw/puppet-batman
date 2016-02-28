define batman::interface (
  String                                  $interface             = "bat-${title}",
  Array[String]                           $interfaces            = [],
  Optional[Integer]                       $orig_interval         = undef,
  Optional[Boolean]                       $ap_isolation          = undef,
  Optional[Boolean]                       $bridge_loop_avoidance = undef,
  Optional[Boolean]                       $distributed_arp_table = undef,
  Optional[Boolean]                       $aggregation           = undef,
  Optional[Boolean]                       $bonding               = undef,
  Optional[Boolean]                       $fragmentation         = undef,
  Optional[Boolean]                       $network_coding        = undef,
  Optional[Boolean]                       $multicast_mode        = undef,
  Optional[Enum['none','batman','routes',
    'tt','bla','dat','nc','all']]         $loglevel              = undef,
  Optional[Enum['off','client','server']] $gw_mode               = undef,
  Optional[Integer[1,256]]                $sel_class             = undef,
  Optional[String]                        $bandwidth             = undef,
  Optional[String]                        $routing_algo          = undef,
  Optional[String]                        $isolation_mark        = undef,
  Optional[String]                        $ip                    = undef,
  Array[String]                           $ip6                   = [],
) {

  require batman
  require batman::params

  $pre_up = []

  $interfaces.each | $_interface | {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE if add ${_interface}" ]
  }
  if $orig_interval != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE orig_interval ${orig_interval}" ]
  }
  if $ap_isolation != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE ap_isolation ${ap_isolation}" ]
  }
  if $bridge_loop_avoidance != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE bridge_loop_avoidance ${bridge_loop_avoidance}" ]
  }
  if $distributed_arp_table != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE distributed_arp_table ${distributed_arp_table}" ]
  }
  if $aggregation != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE aggregation ${aggregation}" ]
  }
  if $bonding != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE bonding ${bonding}" ]
  }
  if $fragmentation != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE fragmentation ${fragmentation}" ]
  }
  if $network_coding != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE network_coding ${network_coding}" ]
  }
  if $multicast_mode != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE multicast_mode ${multicast_mode}" ]
  }
  if $loglevel != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE loglevel ${loglevel}" ]
  }
  if $gw_mode != undef {
    if ($gw_mode == 'client') and ($sel_class != undef) {
      $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${sel_class}" ]
    } elsif ($gw_mode == 'server') and ($bandwidth != undef) {
      $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${bandwidth}" ]
    } else {
      $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode}" ]
    }
  }
  if $routing_algo != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE routing_algo ${routing_algo}" ]
  }
  if $isolation_mark != undef {
    $pre_up = $pre_up + [ "/usr/sbin/batctl -m \$IFACE isolation_mark ${isolation_mark}" ]
  }

  if ($ip) {
    network::inet::manual { $interface:
      post_up => [ "/bin/ip addr add ${ip} dev \$IFACE" ],
    }
  }

  $post_up = []
  $ip6.each | $value | {
    $post_up = $post_up + [ "/bin/ip -6 addr add ${value} dev \$IFACE" ]
  }

  network::inet6::manual { $interface:
    pre_up  => $pre_up,
    post_up => $post_up,
  }

}

