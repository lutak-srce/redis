#
# Class:redis
#
# This module manages Redis
#
class redis (
  $ensure                = 'present',
  $package               = $::redis::params::package,
  $version               = $::redis::params::version,
  $service               = $::redis::params::service,
  $status                = $::redis::params::status,
  $pidfile               = $::redis::params::pidfile,
  $logfile               = $::redis::params::logfile,
  $bind                  = '127.0.0.1',
  $port                  = '6379',
  $unixsocket            = '',
  $unixsocketperm        = '700',
  $tcp_keepalive         = '0',
  $nofile                = '1024',
  $file_owner            = $::redis::params::file_owner,
  $file_group            = $::redis::params::file_group,
  $file_mode             = $::redis::params::file_mode,
  $file_redis_conf       = $::redis::params::file_redis_conf,
  $template_redis_conf   = $::redis::params::template_redis_conf,
  $file_sysconfig        = $::redis::params::file_sysconfig,
  $template_sysconfig    = $::redis::params::template_sysconfig,
  $dir_owner             = $::redis::params::dir_owner,
  $dir_group             = $::redis::params::dir_group,
  $dir_mode              = $::redis::params::dir_mode,
  $dir                   = $::redis::params::dir,
  $config                = {},
) inherits redis::params {

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $service_enable = $status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }
    $service_ensure = $status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }
    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $service_enable = undef
    $service_ensure = stopped
    $file_ensure    = absent
  }

  File {
    ensure  => file,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Package['redis'],
    notify  => Service['redis'],
  }

  package { 'redis':
    ensure => $package_ensure,
    name   => $package,
  }

  file { 'redis_dir':
    ensure => directory,
    path   => $dir,
    owner  => $dir_owner,
    group  => $dir_group,
    mode   => $dir_mode,
  }

  file { 'redis.conf':
    path    => $file_redis_conf,
    content => template($template_redis_conf),
    require => Package['redis'],
    notify  => Service['redis'],
  }

  file { '/etc/sysconfig/redis':
    path    => $file_sysconfig,
    content => template($template_sysconfig),
    require => Package['redis'],
    notify  => Service['redis'],
  }

  service { 'redis':
    ensure  => $service_ensure,
    enable  => $service_enable,
    name    => $service,
    require => [
      File['redis_dir'],
      Package['redis'],
    ],
  }

}
