# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {

  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)

  $storage_management_address       = hiera('openstack::storage::address::management')
  $controller_management_address    = hiera('openstack::controller::address::management')
  $network_management_address       = hiera('openstack::network::address::management')

  # Additional configuration for nova
  
  # Metadata access with quantum: currently this is set in "nova::api", which is only included for controller nodes and multi_host = true compute nodes (i.e. with oldschool nova networking)
  # So, we just add the necessary parameters manually
#  nova_config { 'DEFAULT/service_quantum_metadata_proxy':       value => true }
#  nova_config { 'DEFAULT/quantum_metadata_proxy_shared_secret': value => $gwdg::cloud::base::shared_secret }

  # Set cachmode = writeback
  nova_config { 'DEFAULT/disk_cachemodes':                      value => 'file=writeback' }

  # Enable true, libvirt based live-migrations
  nova_config { 'DEFAULT/live_migration_flag':                  value => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE' }

  # Enable libvirt password injection
  nova_config { 'DEFAULT/libvirt_inject_password':              value => true }

  class { '::nova':
    sql_connection      => $::openstack::resources::connectors::nova,
    glance_api_servers  => "http://${storage_management_address}:9292",
    memcached_servers   => ["${controller_management_address}:11211"],
    rabbit_hosts        => [$controller_management_address],
    rabbit_userid       => hiera('openstack::rabbitmq::user'),
    rabbit_password     => hiera('openstack::rabbitmq::password'),
    debug               => hiera('openstack::debug'),
    verbose             => hiera('openstack::verbose'),
    mysql_module        => '2.2',
    # Handled by ceilometer::agent::compute class
#    notification_driver => ['nova.openstack.common.notifier.rpc_notifier', 'ceilometer.compute.nova_notifier'],
  }

  # TODO: it's important to set up the vnc properly
  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => hiera('openstack::controller::address::vnc_proxy'),
  }

  class { '::nova::compute::neutron':
    libvirt_vif_driver => 'nova.virt.libvirt.vif.LibvirtGenericVIFDriver',
  }

  class { '::nova::network::neutron':
    neutron_admin_password => hiera('openstack::neutron::password'),
    neutron_region_name    => hiera('openstack::region'),
    neutron_admin_auth_url => "http://${controller_management_address}:35357/v2.0",
    neutron_url            => "http://${network_management_address}:9696",
  }

  if hiera('openstack::production') {
    $libvirt_type = 'kvm'
  } else {
    $libvirt_type = 'qemu'
  }

  class { '::nova::compute::libvirt':
    libvirt_type        => $libvirt_type,
    vncserver_listen    => hiera('openstack::nova::vncserver_listen'),
    migration_support   => true,
  }

  # Use NFS for VM storage (to be replaced by cinder)
  if hiera('openstack::production') {

    nfs::client::mount { '/var/lib/nova/instances':
      ensure    => 'mounted',
      server    => '10.108.115.128',
      share     => '/ifs/cloud/production/instances',
      require   => Package['nova-common'],
    }

  } else {

    Nfs::Client::Mount <<| nfstag == 'instances' |>> {
      ensure    => 'mounted',
      require   => Package['nova-common'],
    }
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/openstack/qemu.conf',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}

