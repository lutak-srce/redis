#
# Define: redis::instance
#
# This define creates new instances of Redis
#
define redis::instance (
  $bind          = '0.0.0.0',
  $port          = '6379',
  $datadir       = 'UNSET',
  $nofile        = '1024',
  $tcp_keepalive = '10',
) {

  include ::redis

  File {
    ensure  => file,
    owner   => $::redis::file_owner,
    group   => $::redis::file_group,
    mode    => $::redis::file_mode,
    require => Package['redis'],
    notify  => Service["redis-${title}"],
  }

  # data dir
  if ( $datadir == 'UNSET' ) {
    $dir = "/var/lib/redis-${title}"
  } else {
    $dir = $datadir
  }

  # data dir
  file { "redis_datadir_${title}":
    ensure => directory,
    path   => $dir,
    owner  => $::redis::dir_owner,
    group  => $::redis::dir_group,
    mode   => '0755',
  }

  # pid & log file
  $pidfile = "/var/run/redis/redis-${title}.pid"
  $logfile = "/var/log/redis/redis-${title}.log"

  # config file
  file { "redis.conf_${title}":
    path    => "/etc/redis-${title}.conf",
    content => template('redis/rhel_redis.conf.erb'),
  }

  file { "/etc/sysconfig/redis_${title}":
    path    => "${::redis::file_sysconfig}-${title}",
    content => template($::redis::template_sysconfig),
  }

  # init file
  file { "redis_init_${title}":
    path    => "/etc/rc.d/init.d/redis-${title}",
    mode    => '0755',
    content => template('redis/rhel_redis.sysvinit.erb'),
  }

  service { "redis-${title}":
    ensure  => running,
    enable  => true,
    require => File["redis_datadir_${title}"],
  }

}
