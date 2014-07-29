# Profile to install the horizon web service
class openstack::profile::horizon {

  if hiera('openstack::production') {
    $fqdn = [ '127.0.0.1', hiera('openstack::controller::address::api'), $::fqdn ]
  } else {
    # Add vagrant host IP so NAT to horizon works
    $fqdn = [ '127.0.0.1', hiera('openstack::controller::address::api'), $::fqdn, hiera('vagrant::host::address') ]
  }

  class { '::horizon':
    fqdn            => $fqdn, 
    secret_key      => hiera('openstack::horizon::secret_key'),
    cache_server_ip => hiera('openstack::controller::address::management'),
  }

  openstack::resources::firewall { 'Apache (Horizon)':
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '80',
  }

  openstack::resources::firewall { 'Apache SSL (Horizon)':
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '443', 
  }

  if $::selinux and str2bool($::selinux) != false {
    selboolean{'httpd_can_network_connect':
      value      => on,
      persistent => true,
    }
  }

}
