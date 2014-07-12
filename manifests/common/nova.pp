# Common class for nova installation
# Private, and should not be used on its own
# usage: include from controller, declare from worker
# This is to handle dependency
# depends on openstack::profile::base having been added to a node
class openstack::common::nova ($is_compute    = false) {
  $is_controller = $::openstack::profile::base::is_controller

  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)

  $storage_management_address = hiera('openstack::storage::address::management')
  $controller_management_address = hiera('openstack::controller::address::management')

  # Additional options for nova

  nova_config { 'DEFAULT/default_floating_pool':        value => 'public' }

  # Set overcommit values
  nova_config   { 'DEFAULT/cpu_allocation_ratio':       value => '15.0' }
  nova_config   { 'DEFAULT/ram_allocation_ratio':       value => '1.3' }
  nova_config   { 'DEFAULT/disk_allocation_ratio':      value => '1.0' }

  # Host limits
  nova_config   { 'DEFAULT/max_instances_per_host':     value => '80' }
  nova_config   { 'DEFAULT/max_io_ops_per_host':        value => '2' }
  nova_config   { 'DEFAULT/reserved_host_memory_mb':    value => '16384' }

  class { '::nova':
    sql_connection     => $::openstack::resources::connectors::nova,
    glance_api_servers => "http://${storage_management_address}:9292",
    memcached_servers  => ["${controller_management_address}:11211"],
    rabbit_hosts       => [$controller_management_address],
    rabbit_userid      => hiera('openstack::rabbitmq::user'),
    rabbit_password    => hiera('openstack::rabbitmq::password'),
    debug              => hiera('openstack::debug'),
    verbose            => hiera('openstack::verbose'),
    mysql_module       => '2.2',
  }

  class { '::nova::api':
    admin_password                       => hiera('openstack::nova::password'),
    auth_host                            => $controller_management_address,
    enabled                              => $is_controller,
    neutron_metadata_proxy_shared_secret => hiera('openstack::neutron::shared_secret'),
  }

  class { '::nova::vncproxy':
    host    => hiera('openstack::controller::address::api'),
    enabled => $is_controller,
  }

  class { [
    'nova::scheduler',
    'nova::objectstore',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => $is_controller,
  }

  # TODO: it's important to set up the vnc properly
  class { '::nova::compute':
    enabled                       => $is_compute,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => hiera('openstack::controller::address::vnc_proxy'),
  }

  class { '::nova::compute::neutron': 
#    libvirt_vif_driver => 'nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver',
  }

  class { '::nova::network::neutron':
    neutron_admin_password => hiera('openstack::neutron::password'),
    neutron_region_name    => hiera('openstack::region'),
    neutron_admin_auth_url => "http://${controller_management_address}:35357/v2.0",
    neutron_url            => "http://${controller_management_address}:9696",
  }
}
