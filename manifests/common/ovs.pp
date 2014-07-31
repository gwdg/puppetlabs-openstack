#
class openstack::common::ovs {
  $data_network = hiera('openstack::network::data')
  $data_address = ip_for_network(hiera('openstack::network::data'))

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling        => hiera('openstack::neutron::tunneling'),
    local_ip                => ip_for_network(hiera('openstack::network::data')),
    enabled                 => true,
    tunnel_types            => hiera('openstack::neutron::tunnel_types'),

#    firewall_driver        => 'quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
#    polling_interval       => 2,
  }

  class  { '::neutron::plugins::ml2':
    type_drivers            => hiera('openstack::neutron::type_drivers'),
    tenant_network_types    => hiera('openstack::neutron::tenant_network_types'),
    mechanism_drivers       => hiera('openstack::neutron::mechanism_drivers'),
    tunnel_id_ranges        => hiera('openstack::neutron::tunnel_id_ranges'),
  }
}
