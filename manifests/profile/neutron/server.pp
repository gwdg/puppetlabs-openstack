# The profile to set up the neutron server
class openstack::profile::neutron::server {

  $controller_address_management    = hiera('openstack::controller::address::management')
  $keystone_admin_port              = hiera('openstack::keystone::admin_port')

  openstack::resources::firewall { 'Neutron API':
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '9696', 
  }

  include ::openstack::common::neutron

  # Server def. from ::openstack::common::neutron
  class { '::neutron::server':
    auth_host           => hiera('openstack::controller::address::management'),
    auth_password       => hiera('openstack::neutron::password'),
    database_connection => $::openstack::resources::connectors::neutron,
    enabled             => true,
    sync_db             => false,

    mysql_module        => '2.2',
    api_workers         => hiera('openstack::neutron::server::workers'),
    agent_down_time     => hiera('openstack::neutron::server::agent_down_time'),
  }

  # Setup vif plugin notifications for Nova
  class { 'neutron::server::notifications':
    notify_nova_on_port_status_changes => true,                                                 # Default
    notify_nova_on_port_data_changes   => true,                                                 # Default
    send_events_interval               => '2',                                                  # Default
    nova_url                           => "http://${controller_address_management}:8774/v2",
    nova_admin_auth_url                => "http://${controller_address_management}:${keystone_admin_port}/v2.0",
    nova_admin_username                => 'nova',                                               # Default
    nova_admin_tenant_name             => 'services',                                           # Default
    nova_admin_tenant_id               => undef,
    nova_admin_password                => hiera('openstack::nova::password'),
    nova_region_name                   => hiera('openstack::region'),
  }

  # Additional neutron options
  neutron_config {
    # This may be Icehouse+
    'DEFAULT/rpc_workers':              value => hiera('openstack::neutron::server::workers');
  }

  # Quantum quota setup
  neutron_config {

    'QUOTAS/quota_driver':              value => 'quantum.db.quota_db.DbQuotaDriver';
    'QUOTAS/quota_items':               value => 'network,subnet,port';

    # Default L2 quotas
    'QUOTAS/quota_network':             value => '1';
    'QUOTAS/quota_subnet':              value => '1';
    'QUOTAS/quota_port':                value => '10';

    # Default L3 quotas
    'QUOTAS/quota_router':              value => '1';
    'QUOTAS/quota_floatingip':          value => '3';

    # Default security group quotas
    'QUOTAS/quota_security_group':      value => '10';
    'QUOTAS/quota_security_group_rule': value => '50';
  }

#  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
