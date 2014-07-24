# The base profile for OpenStack. Installs the repository and ntp
class openstack::profile::base {

  # everyone also needs to be on the same clock
  class { '::ntp': 
    servers     => hiera('host::ntp::servers'),
    restrict    => ['127.0.0.1'],
    interfaces  => ['127.0.0.1', ip_for_network(hiera('openstack::network::management'))],
  }

  # all nodes need the OpenStack repository
  class { '::openstack::resources::repo': }

  # Setup apt-cacher-ng (only for vagrant for now)
  if ! hiera('openstack::production') {
    class {'apt':
      proxy_host => 'puppetmaster.cloud.gwdg.de',
      proxy_port => '3142',
    } -> Package<||>
  }

  # database connectors
  class { '::openstack::resources::connectors': }

  # database anchor
  anchor { 'database-service': }

  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)
  $controller_management_address = hiera('openstack::controller::address::management')
  $storage_management_address = hiera('openstack::storage::address::management')

#  $management_matches = ($management_address == $controller_management_address)
#  $storage_management_matches = ($management_address == $storage_management_address)

  $api_network = hiera('openstack::network::api')
  $api_address = ip_for_network($api_network)
  $controller_api_address = hiera('openstack::controller::address::api')
  $storage_api_address    = hiera('openstack::storage::address::api')

#  $api_matches = ($api_address == $controller_api_address)
#  $storage_api_matches = ($api_address == $storage_api_address)

#  $is_controller = ($management_matches and $api_matches)
#  $is_storage    = ($storage_management_matches and $storage_api_matches)
}
