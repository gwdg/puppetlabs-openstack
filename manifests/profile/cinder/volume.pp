# The profile to install the volume service
class openstack::profile::cinder::volume {
  $management_network = hiera('openstack::network::management')
  $management_address = ip_for_network($management_network)

  openstack::resources::firewall { 'ISCSI API': port => '3260', }

  include ::openstack::common::cinder

#  class { '::cinder::setup_test_volume':
#    volume_name => 'cinder-volumes',
#    size        => hiera('openstack::cinder::volume_size')
#  } ->

  class { '::cinder::volume':
    package_ensure => true,
    enabled        => true,
  }

#  class { '::cinder::volume::iscsi':
#    iscsi_ip_address  => $management_address,
#    volume_group      => 'cinder-volumes',
#  }

  # Use NFS backend for now
  class { 'cinder::volume::nfs':

    nfs_servers             => hiera('openstack::cinder::nfs_servers'),
    nfs_mount_options       => undef,
    nfs_disk_util           => undef,
    nfs_sparsed_volumes     => true,
    nfs_mount_point_base    => undef,
    nfs_shares_config       => '/etc/cinder/shares.conf'
  }


}
