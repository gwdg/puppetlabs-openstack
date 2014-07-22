# The profile to install the Keystone service
class openstack::profile::keystone_auth {

  class { '::nova::keystone::auth':
    password            => hiera('openstack::nova::password'),
    public_address      => hiera('openstack::controller::address::api'),
    admin_address       => hiera('openstack::controller::address::management'),
    internal_address    => hiera('openstack::controller::address::management'),
    region              => hiera('openstack::region'),
    cinder              => true,
  }

  class { '::neutron::keystone::auth':
    password         => hiera('openstack::neutron::password'),
    public_address   => hiera('openstack::network::address::api'),
    admin_address    => hiera('openstack::network::address::management'),
    internal_address => hiera('openstack::network::address::management'),
    region           => hiera('openstack::region'),
  }

  class  { '::glance::keystone::auth':
    password         => hiera('openstack::glance::password'),
    public_address   => hiera('openstack::storage::address::api'),
    admin_address    => hiera('openstack::storage::address::management'),
    internal_address => hiera('openstack::storage::address::management'),
    region           => hiera('openstack::region'),
  }

  class { '::heat::keystone::auth':
    password         => hiera('openstack::heat::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  class { '::heat::keystone::auth_cfn':
    password         => hiera('openstack::heat::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  class { '::ceilometer::keystone::auth':
    password         => hiera('openstack::ceilometer::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  class { '::cinder::keystone::auth':
    password         => hiera('openstack::cinder::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  class { 'swift::keystone::auth':
    password         => hiera('openstack::swift::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }
}
