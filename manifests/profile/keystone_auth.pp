# The profile to install the Keystone service
class openstack::profile::keystone_auth {

#Exec<| title == 'keystone-manage db_sync'|> -> Keystone_endpoint<||>
#Exec<| title == 'keystone-manage pki_setup'|>

#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_endpoint<||> 
#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_user<||> 
#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_role<||> 
#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_service<||> 
#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_user_role<||> 
#  Exec<| title == 'keystone-manage db_sync'|> -> Keystone_tenant<||>

  class { '::nova::keystone::auth':
    password            => hiera('openstack::nova::password'),
    public_address      => hiera('openstack::controller::address::api'),
    admin_address       => hiera('openstack::controller::address::management'),
    internal_address    => hiera('openstack::controller::address::management'),
    region              => hiera('openstack::region'),
    cinder              => true,
#    require               => Class['::keystone'],
  }

  class { '::neutron::keystone::auth':
    password         => hiera('openstack::neutron::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#    require               => Class['::keystone'],
  }

  class  { '::glance::keystone::auth':
    password         => hiera('openstack::glance::password'),
    public_address   => hiera('openstack::storage::address::api'),
    admin_address    => hiera('openstack::storage::address::management'),
    internal_address => hiera('openstack::storage::address::management'),
    region           => hiera('openstack::region'),
#    require               => Class['::keystone'],
  }

  class { '::heat::keystone::auth':
    password         => hiera('openstack::heat::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#    require               => Class['::keystone'],
  }

  class { '::heat::keystone::auth_cfn':
    password         => hiera('openstack::heat::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#require               => Class['::keystone'],
  }

  class { '::ceilometer::keystone::auth':
    password         => hiera('openstack::ceilometer::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#require               => Class['::keystone'],
  }

  class { '::cinder::keystone::auth':
    password         => hiera('openstack::cinder::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#require               => Class['::keystone'],
  }

  class { 'swift::keystone::auth':
    password         => hiera('openstack::swift::password'),
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
#require               => Class['::keystone'],
  }
}
