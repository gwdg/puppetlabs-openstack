class openstack::role::storage inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::glance::api': }
  class { '::openstack::profile::cinder::volume': }
  class { '::openstack::profile::auth_file': }

  class { '::openstack::setup::cirros': }
}
