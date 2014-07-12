# The profile to set up the neutron server
class openstack::profile::neutron::server {
  openstack::resources::controller { 'neutron': }
  openstack::resources::database { 'neutron': } 
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron

  # Try to make due without ovs stuff on the controller node
#  include ::openstack::common::ovs

  # Server def. from ::openstack::common::neutron
  class { '::neutron::server':
    auth_host           => hiera('openstack::controller::address::management'),
    auth_password       => hiera('openstack::neutron::password'),
    database_connection => $::openstack::resources::connectors::neutron,
    enabled             => $::openstack::profile::base::is_controller,
    sync_db             => $::openstack::profile::base::is_controller,
    mysql_module        => '2.2',
  }

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
