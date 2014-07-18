# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {

  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)

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

  class { '::compute::common::nova':
    is_compute => true,
  }

  class { '::nova::compute::libvirt':
    if hiera('openstack::production') {
       libvirt_type     => 'kvm',
     } else {
       libvirt_type     => 'qvm',
    }
    libvirt_type        => hiera('openstack::nova::libvirt_type'),
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

  # Not sure if this is necessary
#  file { '/etc/libvirt/qemu.conf':
#    ensure => present,
#    source => 'puppet:///modules/openstack/qemu.conf',
#    mode   => '0644',
#    notify => Service['libvirt'],
#  }

#  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}
