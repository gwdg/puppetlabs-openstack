# The base profile for OpenStack. Installs the repository and ntp
class openstack::profile::base {

  # Everyone also needs to be on the same clock
  class { '::ntp': 
    servers     => hiera('host::ntp::servers'),
    restrict    => ['127.0.0.1'],
    interfaces  => ['127.0.0.1', ip_for_network(hiera('openstack::network::management'))],
  }

  # Disable NIC offloading (kill performance for OVS setup)
  package { 'ethtool': }

  exec { 'disable generic-receive-offload': 
    command => 'ethtool --offload eth0 gro off',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    onlyif  => 'test `ethtool --show-offload eth0 | grep generic-receive-offload | cut -d" " -f2` = on',
    require => Package['ethtool'],
  }  

  # All nodes need the OpenStack repository
  class { '::openstack::resources::repo': }

  # Setup apt-cacher-ng (only for vagrant for now)
  if ! hiera('openstack::production') {
    class {'apt':
      proxy_host => 'puppetmaster.cloud.gwdg.de',
      proxy_port => '3142',
    } -> Package<||>
  }

  # Database connectors
  class { '::openstack::resources::connectors': }

  # Database anchor
  anchor { 'database-service': }

  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)
  $controller_management_address = hiera('openstack::controller::address::management')
  $storage_management_address = hiera('openstack::storage::address::management')

  $api_network = hiera('openstack::network::api')
  $api_address = ip_for_network($api_network)
  $controller_api_address = hiera('openstack::controller::address::api')
  $storage_api_address    = hiera('openstack::storage::address::api')

}
