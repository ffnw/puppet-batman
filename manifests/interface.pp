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

  include router
  include batman
  include batman::params

  $_interfaces = $interfaces.map | $value | {
    "/usr/local/sbin/batctl -m \$IFACE if add ${value}"
  }

  if $orig_interval != undef {
    $_orig_interval = [ "/usr/local/sbin/batctl -m \$IFACE orig_interval ${orig_interval}" ]
  } else {
    $_orig_interval = []
  }

  if $ap_isolation != undef {
    $_ap_isolation = [ "/usr/local/sbin/batctl -m \$IFACE ap_isolation ${ap_isolation}" ]
  } else {
    $_ap_isolation = []
  }

  if $bridge_loop_avoidance != undef {
    $_bridge_loop_avoidance = [ "/usr/local/sbin/batctl -m \$IFACE bridge_loop_avoidance ${bridge_loop_avoidance}" ]
  } else {
    $_bridge_loop_avoidance = []
  }

  if $distributed_arp_table != undef {
    $_distributed_arp_table = [ "/usr/local/sbin/batctl -m \$IFACE distributed_arp_table ${distributed_arp_table}" ]
  } else {
    $_distributed_arp_table = []
  }

  if $aggregation != undef {
    $_aggregation = [ "/usr/local/sbin/batctl -m \$IFACE aggregation ${aggregation}" ]
  } else {
    $_aggregation = []
  }

  if $bonding != undef {
    $_bonding = [ "/usr/local/sbin/batctl -m \$IFACE bonding ${bonding}" ]
  } else {
    $_bonding = []
  }

  if $fragmentation != undef {
    $_fragmentation = [ "/usr/local/sbin/batctl -m \$IFACE fragmentation ${fragmentation}" ]
  } else {
    $_fragmentation = []
  }

  if $network_coding != undef {
    $_network_coding = [ "/usr/local/sbin/batctl -m \$IFACE network_coding ${network_coding}" ]
  } else {
    $_network_coding = []
  }

  if $multicast_mode != undef {
    $_multicast_mode = [ "/usr/local/sbin/batctl -m \$IFACE multicast_mode ${multicast_mode}" ]
  } else {
    $_multicast_mode = []
  }

  if $loglevel != undef {
    $_loglevel = [ "/usr/local/sbin/batctl -m \$IFACE loglevel ${loglevel}" ]
  } else {
    $_loglevel = []
  }

  if $gw_mode != undef {
    if ($gw_mode == 'client') and ($sel_class != undef) {
      $_gw_mode = [ "/usr/local/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${sel_class}" ]
    } elsif ($gw_mode == 'server') and ($bandwidth != undef) {
      $_gw_mode = [ "/usr/local/sbin/batctl -m \$IFACE gw_mode ${gw_mode} ${bandwidth}" ]
    } else {
      $_gw_mode = [ "/usr/local/sbin/batctl -m \$IFACE gw_mode ${gw_mode}" ]
    }
  } else {
    $_gw_mode = []
  }

  if $routing_algo != undef {
    $_routing_algo = [ "/usr/local/sbin/batctl -m \$IFACE routing_algo ${routing_algo}" ]
  } else {
    $_routing_algo = []
  }

  if $isolation_mark != undef {
    $_isolation_mark = [ "/usr/local/sbin/batctl -m \$IFACE isolation_mark ${isolation_mark}" ]
  } else {
    $_isolation_mark = []
  }

  $_batman_options = $_interfaces + $_orig_interval + $_ap_isolation + $_bridge_loop_avoidance + $_distributed_arp_table + $_aggregation + $_bonding + $_fragmentation + $_network_coding + $_multicast_mode + $_loglevel + $_gw_mode + $_routing_algo + $_isolation_mark

  if ($ip) {
    network::inet::manual { $interface:
      pre_up  => [ "/sbin/iptables -A INPUT -i \$IFACE -p icmp --icmp-type router-advertisement -j DROP",
                   "/sbin/iptables -A FORWARD -i \$IFACE -p icmp --icmp-type router-advertisement -j DROP",
                   "/sbin/iptables -A INPUT -i \$IFACE -dport 67:68 -sport 67:68 -j DROP",
                   "/sbin/iptables -A FORWARD -i \$IFACE -dport 67:68 -sport 67:68 -j DROP" ],
      post_up   => [ "/bin/ip -4 addr add ${ip} dev \$IFACE" ],
    }
  }

  $v6_addresses = $ip6.map | $value | {
    "/bin/ip -6 addr add ${value} dev \$IFACE"
  }

  network::inet6::manual { $interface:
    pre_up  => [ "/sbin/ip6tables -A INPUT -i \$IFACE -p icmpv6 --icmpv6-type router-advertisement -j DROP",
                 "/sbin/ip6tables -A FORWARD -i \$IFACE -p icmpv6 --icmpv6-type router-advertisement -j DROP",
                 "/sbin/ip6tables -A INPUT -i \$IFACE -dport 67:68 -sport 67:68 -j DROP",
                 "/sbin/ip6tables -A FORWARD -i \$IFACE -dport 67:68 -sport 67:68 -j DROP" ],
    post_up => $_batman_options + $v6_addresses,
  }

}

