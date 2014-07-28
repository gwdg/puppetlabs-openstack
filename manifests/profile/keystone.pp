# The profile to install the Keystone service
class openstack::profile::keystone {

  openstack::resources::firewall { 'Keystone API': 
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '5000', 
  }

  $bind_host    = hiera('openstack::controller::address::management')
  $admin_port   = hiera('openstack::keystone::admin_port')

  class { '::keystone':
    admin_token         => hiera('openstack::keystone::admin_token'),
    sql_connection      => $::openstack::resources::connectors::keystone,
    verbose             => hiera('openstack::verbose'),
    debug               => hiera('openstack::debug'),
    enabled             => true,
    admin_bind_host     => $bind_host,
    public_bind_host    => $bind_host,
    admin_port          => $admin_port,
    admin_endpoint      => "http://${bind_host}:${admin_port}/v2.0/",
    token_expiration    => hiera('openstack::keystone::token_expiration'),
    mysql_module        => '2.2',
  }

  class { '::keystone::roles::admin':
    email        => hiera('openstack::keystone::admin_email'),
    password     => hiera('openstack::keystone::admin_password'),
    admin_tenant => 'admin',
  }

  class { 'keystone::endpoint':
    public_address   => hiera('openstack::controller::address::api'),
    admin_address    => hiera('openstack::controller::address::management'),
    internal_address => hiera('openstack::controller::address::management'),
    region           => hiera('openstack::region'),
  }

  # Keystone LDAP setup
  if hiera('openstack::keystone::ldap') {

    $ldap_address_management = hiera('openstack::ldap::address::management')

    class { 'keystone::ldap':

      url            => "ldap://${ldap_address_management}",
      user           => 'cn=admin,dc=computecloud,dc=gwdg,dc=de',
      password       => 'test',
      suffix         => 'dc=computecloud,dc=gwdg,dc=de',
      user_tree_dn   => 'ou=Users,dc=computecloud,dc=gwdg,dc=de',
      tenant_tree_dn => 'ou=Groups,dc=computecloud,dc=gwdg,dc=de',
      role_tree_dn   => 'ou=Roles,dc=computecloud,dc=gwdg,dc=de'
    }
  }

  # Make sure index is set on token.expire column (not sue if still necessary for Havana)
#  exec { 'Add index to token.expire':
#    command             => "mysql -u ${gwdg::cloud::base::keystone_db_user} -p${$gwdg::cloud::base::keystone_db_password} -e 'ALTER TABLE token ADD INDEX idx_token_expires (expires);' keystone",
#    path                => '/usr/bin',
#    user                => 'root',
#    refreshonly         => true,
#    subscribe           => Exec['keystone-manage db_sync'],
#  }

}
