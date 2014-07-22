# Starts up standard firewall rules. Pre-runs

class openstack::profile::firewall::pre {

  # Set up the initial firewall rules for all nodes
  if $::osfamily == 'RedHat' {
    firewallchain { 'INPUT:filter:IPv4':
      purge   => true,
      ignore  => ['neutron','virbr0'],
      before  => Firewall['0001 - related established'],
      require => [ Class['::openstack::resources::repo::epel'],
                   Class['::openstack::resources::repo::rdo'] ],
    }
  } elsif $::osfamily == 'Debian' {
    firewallchain { 'INPUT:filter:IPv4':
      purge   => true,
      ignore  => ['neutron','virbr0'],
      before  => Firewall['0001 - related established'],
      require => [ Class['::openstack::resources::repo::uca'] ],
    }
  }

  class { '::firewall': }

  # Default firewall rules, based on the RHEL defaults
  firewall { '0001 - related established':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
    before  => [ Class['::firewall'] ],
  } ->
  firewall { '0002 - localhost':
    proto  => 'icmp',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0003 - localhost':
    proto  => 'all',
    action => 'accept',
    source => '127.0.0.1',
  } ->
  firewall { '0022 - ssh':
    proto  => 'tcp',
    state  => ['NEW', 'ESTABLISHED', 'RELATED'],
    action => 'accept',
    port   => 22,
    before => [ Firewall['8999 - Accept all management network traffic'] ],
  }

  if ! hiera('openstack::production') {

    # Make sure we also have full access from IP behind the hostname (i.e. from provisioning network) as it is used locally as source address (e.g. for rabbitmq control)
    firewall { '0004 - virtualbox hostname':
      proto     => 'all',
      action    => 'accept',
      source    => ip_for_network(hiera('openstack::network::provisioning')),
      before    => [ Class['::firewall'] ],
    }

    # Accept all traffic from virtualbox gateway as it is used for nat
    firewall { '0005 - virtualbox gateway':
      proto     => 'all',
      action    => 'accept',
      source    => hiera('vagrant::gateway::address'),
      before    => [ Class['::firewall'] ],
    }

    # Do DNAT, so that networks match with production infrastructure
    firewall { '0006 - virtualbox dnat':
      proto     => 'all',
      table     => 'nat',
      chain     => 'PREROUTING',
      source    => hiera('vagrant::gateway::address'),
      todest    => ip_for_network(hiera('openstack::network::management')),
      jump      => 'DNAT',
      before    => [ Class['::firewall'] ],
    }

  }
}
