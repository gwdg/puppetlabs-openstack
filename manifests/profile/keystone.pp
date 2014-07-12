# The profile to install the Keystone service
class openstack::profile::keystone {

  openstack::resources::controller { 'keystone': }
  openstack::resources::database { 'keystone': }
  openstack::resources::firewall { 'Keystone API': port => '5000', }

  include ::openstack::common::keystone

  class { 'keystone::endpoint':
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  # Keystone LDAP setup
  if ( hiera('openstack::keyston::ldap') == true ) {

    class { 'keystone::ldap':

      url            => "ldap://${hiera('openstack::ldap::address::management')}",
      user           => 'cn=admin,dc=computecloud,dc=gwdg,dc=de',
      password       => 'test',
      suffix         => 'dc=computecloud,dc=gwdg,dc=de',
      user_tree_dn   => 'ou=Users,dc=computecloud,dc=gwdg,dc=de',
      tenant_tree_dn => 'ou=Groups,dc=computecloud,dc=gwdg,dc=de',
      role_tree_dn   => 'ou=Roles,dc=computecloud,dc=gwdg,dc=de'
    }
  }

  $tenants = hiera('openstack::tenants')
  $users = hiera('openstack::users')
  create_resources('openstack::resources::tenant', $tenants)
  create_resources('openstack::resources::user', $users)
}
