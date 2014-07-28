class openstack::common::keystone {

#  if $::openstack::profile::base::is_controller {
#    $admin_bind_host = '0.0.0.0'
#  } else {
#    $admin_bind_host = hiera('openstack::controller::address::management')
#  }

  $bind_host    = hiera('openstack::controller::address::management')
  $admin_port   = hiera('openstack::keystone::admin_port')

  class { '::keystone':
    admin_token         => hiera('openstack::keystone::admin_token'),
    sql_connection      => $::openstack::resources::connectors::keystone,
    verbose             => hiera('openstack::verbose'),
    debug               => hiera('openstack::debug'),
#    enabled             => $::openstack::profile::base::is_controller,
    enabled             => true,
    admin_bind_host     => $bind_host,
    public_bind_host    => $bind_host,
    admin_port          => $admin_port,
    admin_endpoint      => "http://${bind_host}:${admin_port}/v2.0/",
    mysql_module        => '2.2',
  }

  class { '::keystone::roles::admin':
    email        => hiera('openstack::keystone::admin_email'),
    password     => hiera('openstack::keystone::admin_password'),
    admin_tenant => 'admin',
  }
}
