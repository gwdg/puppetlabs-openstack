# post-firewall rules to reject remaining traffic
class openstack::profile::firewall::post {

  firewall { '8999 - Accept all management network traffic':
    proto       => 'all',
    state       => ['NEW'],
    action      => 'accept',
    source      => hiera('openstack::network::management'),
    destination => ip_for_network(hiera('openstack::network::management')),
  } ->

  # Log all rejected traffic
  firewall { '9998 - Log rejected remaining traffic':
    proto       => 'all',
#    limit       => '2/min',
    log_level   => 'warn',
    log_prefix  => '[IPTABLES] dropped:',
    jump        => 'LOG',
  } ->

  # Reject all remaining traffic
  firewall { '9999 - Reject remaining traffic':
    proto  => 'all',
    action => 'reject',
    reject => 'icmp-host-prohibited',
    source => '0.0.0.0/0',
  }
}
