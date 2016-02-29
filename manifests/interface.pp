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

  include batman
  include batman::params

  $_interfaces = []
  $interfaces.each | $value | {
    $_interfaces = $_interfaces + [ "/usr/sbin/batctl -m \$IFACE if add ${value}" ]
  }

  if $orig_interval != undef {
    $_orig_interval = [ "/usr/sbin/batctl -m \$IFACE orig_interval ${orig_interval}" ]
  } else {
    $_orig_interval = []
  }

  if $ap_isolation != undef {
    $_ap_isolation = [ "/usr/sbin/batctl -m \$IFACE ap_isolation ${ap_isolation}" ]
  } else {
    $_ap_isolation = []
  }

  if $bridge_loop_avoidance != undef {
    $_bridge_loop_avoidance = [ "/usr/sbin/batctl -m \$IFACE bridge_loop_avoidance ${bridge_loop_avoidance}" ]
  } else {
    $_bridge_loop_avoidance = []
  }

  if $distributed_arp_table != undef {
    $_distributed_arp_table = [ "/usr/sbin/batctl -m \$IFACE distributed_arp_table ${distributed_arp_table}" ]
  } else {
    $_distributed_arp_table = []
  }

  if $aggregation != undef {
    $_aggregation = [ "/usr/sbin/batctl -m \$IFACE aggregation ${aggregation}" ]
  } else {
    $_aggregation = []
  }

  if $bonding != undef {
    $_bonding = [ "/usr/sbin/batctl -m \$IFACE bonding ${bonding}" ]
  } else {
    $_bonding = []
  }

  if $fragmentation != undef {
    $_fragmentation = [ "/usr/sbin/batctl -m \$IFACE fragmentation ${fragmentation}" ]
  } else {
    $_fragmentation = []
  }

  if $network_coding != undef {
    $_network_coding = [ "/usr/sbin/batctl -m \$IFACE network_coding ${network_coding}" ]
  } else {
    $_network_coding = []
  }

  if $multicast_mode != undef {
    $_multicast_mode = [ "/usr/sbin/batctl -m \$IFACE multicast_mode ${multicast_mode}" ]
  } else {
    $_multicast_mode = []
  }

  if $loglevel != undef {
    $_loglevel = [ "/usr/sbin/batctl -m \$IFACE loglevel ${loglevel}" ]
  } else {
    $_loglevel = []
  }

  if $gw_mode != undef {
    if ($gw_mode == 'client') and ($sel_class != undef) {
      $_gw_mode = [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${sel_class}" ]
    } elsif ($gw_mode == 'server') and ($bandwidth != undef) {
      $_gw_mode = [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${bandwidth}" ]
    } else {
      $_gw_mode = [ "/usr/sbin/batctl -m \$IFACE gw_mode ${gw_mode}" ]
    }
  } else {
    $_gw_mode = []
  }

  if $routing_algo != undef {
    $_routing_algo = [ "/usr/sbin/batctl -m \$IFACE routing_algo ${routing_algo}" ]
  } else {
    $_routing_algo = []
  }

  if $isolation_mark != undef {
    $_isolation_mark = [ "/usr/sbin/batctl -m \$IFACE isolation_mark ${isolation_mark}" ]
  } else {
    $_isolation_mark = []
  }

  $pre_up = $_interfaces + $_orig_interval + $_ap_isolation + $_bridge_loop_avoidance + $_distributed_arp_table + $_aggregation + $_bonding + $_fragmentation + $_network_coding + $_multicast_mode + $_loglevel + $_gw_mode + $_routing_algo + $_isolation_mark

  if ($kernel_table) {
    $ip4_rule_up   = [ "/bin/ip -4 rule add pref 31000 iif $IFACE table ${kernel_table}",
                       "/bin/ip -4 rule add pref 31001 iif $IFACE unreachable", ]
    $ip6_rule_up   = [ "/bin/ip -6 rule add pref 31000 iif $IFACE table ${kernel_table}",
                       "/bin/ip -6 rule add pref 31001 iif $IFACE unreachable", ]
    $ip4_rule_down = [ "/bin/ip -4 rule del pref 31000 iif $IFACE table ${kernel_table}",
                       "/bin/ip -4 rule del pref 31001 iif $IFACE unreachable", ]
    $ip6_rule_down = [ "/bin/ip -6 rule del pref 31000 iif $IFACE table ${kernel_table}",
                       "/bin/ip -6 rule del pref 31001 iif $IFACE unreachable", ]
  } else {
    $ip4_rule_up   = []
    $ip6_rule_up   = []
    $ip4_rule_down = []
    $ip6_rule_down = []
  }

  if ($ip) {
    network::inet::manual { $interface:
      pre_up    => $ip4_rule_up,
      post_up   => [ "/bin/ip -4 addr add ${ip} dev \$IFACE" ],
      post_down => $ip4_rule_down,
    }
  }

  $post_up = []
  $ip6.each | $value | {
    $post_up = $post_up + [ "/bin/ip -6 addr add ${value} dev \$IFACE" ]
  }

  network::inet6::manual { $interface:
    pre_up    => $pre_up + $ip6_rule_up,
    post_up   => $post_up,
    post_down => $ip6_rule_down,
  }

}

