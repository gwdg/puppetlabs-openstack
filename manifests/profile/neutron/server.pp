# The profile to set up the neutron server
class openstack::profile::neutron::server {

  # Run the neutron server on the network node
#  openstack::resources::controller { 'neutron': }
#  openstack::resources::database { 'neutron': } 

  openstack::resources::firewall { 'Neutron API':
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '9696', 
  }

  include ::openstack::common::neutron
#  include ::openstack::common::ovs

  # Server def. from ::openstack::common::neutron
  class { '::neutron::server':
    auth_host           => hiera('openstack::controller::address::management'),
    auth_password       => hiera('openstack::neutron::password'),
    database_connection => $::openstack::resources::connectors::neutron,
#    enabled             => $::openstack::profile::base::is_controller,
#    sync_db             => $::openstack::profile::base::is_controller,
    enabled             => true,
    sync_db             => false,

    mysql_module        => '2.2',
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
