#
# Class: redis::params
#
# This module contains defaults for redis modules
#
class redis::params {

  # module specific settings (server)
  $file_owner     = 'root'
  $file_group     = 'root'
  $file_mode      = '0644'
  $dir_owner      = 'redis'
  $dir_group      = 'redis'
  $dir_mode       = '0755'

  # module dependencies
  $dependency_class = 'redis::dependency'
  $my_class         = undef

  # install package depending on major version
  case $::osfamily {
    default: {
      fail("Class['redis::params']: Unsupported osfamily: ${::osfamily}")
    }
    /(RedHat|redhat|amazon)/: {
      $package             = 'redis'
      $version             = 'present'
      $service             = 'redis'
      $status              = 'enabled'
      $pidfile             = '/var/run/redis/redis.pid'
      $logfile             = '/var/log/redis/redis.log'
      $file_redis_conf     = '/etc/redis.conf'
      $template_redis_conf = 'redis/rhel_redis.conf.erb'
      $file_sysconfig      = '/etc/sysconfig/redis'
      $template_sysconfig  = 'redis/sysconfig.erb'
      $dir                 = '/var/lib/redis/'
    }
    /(Debian|debian)/: {
      $package             = 'redis-server'
      $version             = 'present'
      $service             = 'redis-server'
      $status              = 'enabled'
      $pidfile             = '/var/run/redis/redis-server.pid'
      $logfile             = '/var/log/redis/redis-server.log'
      $file_redis_conf     = '/etc/redis/redis.conf'
      $template_redis_conf = 'redis/debian_redis.conf.erb'
      $dir                 = '/var/lib/redis'
    }
  }

}
