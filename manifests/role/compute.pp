# OpenStack compute role
class openstack::role::compute inherits ::openstack::role {
  # Deactivate firewall profile (puppet provider crashes due to openvswitch / neutron rules)
#  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::neutron::agent': }
  class { '::openstack::profile::nova::compute': }
  class { '::openstack::profile::ceilometer::agent': }
}
