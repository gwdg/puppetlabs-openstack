# Firewall rule abstraction
#
# - source_net: source network (used for source network + interface)
# - target_net: target network to derive host target IP
# - port: target port

define openstack::resources::firewall(
    $source_net,
    $target_net,
    $port,
     
  ) {
  # The firewall module can not handle managed rules with a leading 9 properly
  if $port =~ /9[0-9]+/ {
    firewall { "8${port} - ${title}":
      proto         => 'tcp',
      state         => ['NEW'],
      action        => 'accept',
      iniface       => device_for_network($source_net),
      source        => $source_net,
      destination   => ip_for_network($target_net),
      dport         => $port,
      before        => Firewall['8999 - Accept all management network traffic'],
    }
  } else {
    firewall { "${port} - ${title}":
      proto         => 'tcp',
      state         => ['NEW'],
      action        => 'accept',
      iniface       => device_for_network($source_net),
      source        => $source_net,
      destination   => ip_for_network($target_net),
      dport         => $port,
      before        => Firewall['8999 - Accept all management network traffic'],
    }
  }
}
