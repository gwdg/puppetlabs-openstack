class openstack::role::network inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::neutron::router': }    ->
  class { '::openstack::profile::neutron::server': }    ->
  class { '::openstack::setup::sharednetwork': }
  class { '::openstack::profile::auth_file': }
}
