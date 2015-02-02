#
# Class vitess::vtctld
#
# Manage vitess management system, vtctld
#
class vitess::vtctld (
  $zk_hosts = ['localhost'],
  $zk_port = 2181,
) {

  ##
  # zk-client-conf.json - zookeeper client configuration
  ##
  file {'/etc/vitess/zk-client-conf.json':
    ensure  => file,
    content => template("${module_name}/zk-client-conf.json.erb"),
    notify  => Service['vtctld']
  }

  file { '/etc/init/vtctld.conf':
    ensure => file,
    source => "puppet:///modules/${module_name}/init/vtctld.conf",
  }

  service {'vtctld':
    ensure  => running,
    require => [ File['/etc/init/vtctld.conf'],
                 File['/usr/local/share/vitess/vtctld']
               ],
  }

  file {'/usr/local/share/vitess/vtctld':
    ensure  => directory,
    source  => '/usr/local/src/github.com/youtube/vitess/go/cmd/vtctld',
    recurse => true,
  }

}
