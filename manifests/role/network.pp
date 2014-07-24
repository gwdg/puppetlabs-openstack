class openstack::role::network inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::neutron::router': }    ->
  class { '::openstack::profile::neutron::server': }    ->
#  class { '::openstack::setup::sharednetwork': }
  class { '::openstack::profile::auth_file': }


  # Allow all tunneling traffic on data network
  firewall { '8998 - Accept all data (overlay) network traffic':
    proto       => 'all',
    action      => 'accept',
    source      => hiera('openstack::network::data'),
    destination => ip_for_network(hiera('openstack::network::data')),
    before      => [ Class['::firewall'] ],
  }
}
