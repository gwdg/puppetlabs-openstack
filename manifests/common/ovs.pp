#
class openstack::common::ovs {
  $data_network = hiera('openstack::network::data')
  $data_address = ip_for_network($data_network)
  $enable_tunneling = hiera('openstack::neutron::tunneling')
  $tunnel_types = hiera('openstack::neutron::tunnel_types')
  $tenant_network_type = hiera('openstack::neutron::tenant_network_type')
  $network_vlan_ranges = hiera('openstack::neutron::network_vlan_ranges')

  class { '::neutron::agents::ovs':

    enable_tunneling => true,
    local_ip         => $data_address,
    enabled          => true,
    tunnel_types     => ['gre',],
  }

  class  { '::neutron::plugins::ovs':
    tenant_network_type => $tenant_network_type,
    network_vlan_ranges => $network_vlan_ranges
  }
}
