#
# Class vitess::config
#
class vitess::config (
  $zk_hosts = ['localhost'],
  $zk_port = 2181,  
) {

  include vitess::service

  ##
  # Base config directory
  ##
  file {'/etc/vitess/':
    ensure => directory,
  }

  ##
  # zk-client-conf.json - zookeeper client configuration
  ##
  file {'/etc/vitess/zk-client-conf.json':
    ensure  => file,
    content => template("${module_name}/zk-client-conf.json.erb"),
    notify  => Service['vtctld']
  }

}
