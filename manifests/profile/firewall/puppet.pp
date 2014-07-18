class openstack::profile::firewall::puppet {

  openstack::resources::firewall { 'Puppet': 
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '8140' 
  }

  openstack::resources::firewall { 'Puppet Orchestration': 
    source_net  => hiera('openstack::network::management'),
    target_net  => hiera('openstack::network::management'),
    port        => '61613'
  }

#  openstack::resources::firewall { 'Puppet Console': port => '443' }
}
