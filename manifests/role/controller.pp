class openstack::role::controller inherits ::openstack::role {
  class { '::openstack::profile::firewall': }
  class { '::openstack::profile::rabbitmq': } ->
  class { '::openstack::profile::memcache': } ->
  class { '::openstack::profile::mysql': } ->
  class { '::openstack::profile::mongodb': } ->
  class { '::openstack::profile::keystone': } ->
  class { '::openstack::profile::keystone_auth': } ->
  class { '::openstack::profile::ceilometer::api': } ->
  class { '::openstack::profile::glance::auth': } ->
  class { '::openstack::profile::cinder::api': } ->
  class { '::openstack::profile::nova::api': } ->
#  class { '::openstack::profile::neutron::server': } ->
  class { '::openstack::profile::heat::api': } ->
  class { '::openstack::profile::horizon': }
  class { '::openstack::profile::auth_file': }

  # Ratelimits (see http://docs.openstack.org/grizzly/openstack-compute/admin/content/configuring-compute-API.html for defaults)
  nova_paste_api_ini    { 'filter:ratelimit/limits':    value => '(POST, "*", .*, 1000, MINUTE);(POST, "*/servers", ^/servers, 500, DAY);(PUT, "*", .*, 1000, MINUTE);(GET, "*changes-since*", .*changes-since.*, 300, MINUTE);(DELETE, "*", .*, 1000, MINUTE)'; }

}
