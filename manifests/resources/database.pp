# Wrapper for *::db::mysql stuff
define openstack::resources::database () {
  class { "::${title}::db::mysql":
    user          => $title,
    password      => hiera('openstack::mysql::service_password'),
    dbname        => $title,
    host          => hiera('openstack::controller::address::management'),
    allowed_hosts => hiera('openstack::mysql::allowed_hosts'),
    mysql_module  => '2.2',
    collate       => 'utf8_unicode_ci',
    charset       => 'utf8',
    require       => Anchor['database-service'],
  }
}
