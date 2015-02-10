#
# Class vitess::vttablet
#
class vitess::vttablet (
  $cell         = 'test',
  $keyspace     = ['test_keyspace'],
  $vtctl_server = 'localhost',
  $vtctl_port   = 15000,
) {

  file { '/etc/init/vttablet.conf':
    ensure => file,
    source => "puppet:///modules/${module_name}/init/vttablet.conf",
  }

  service {'vttablet':
    ensure  => running,
    require => File['/etc/init/vttablet.conf'],
  }

  ##
  # Need to see a condition to run this, for now its just refresh after
  # Service[vttablet]
  ##
  exec {'RebuildKeyspaceGraph':
    command     => "vtctlclient -server ${vtctl_server}:${vtctl_port} RebuildKeyspaceGraph ${keyspace}",
    refreshonly => true,
    subscribe   => Service['vttablet'],
  }

  ##
  # Need to convert these to puppet native types, now adding as execs, currently
  # only support single keyspace
  ##
  exec {'ReparantShard':
    command => "vtctlclient -server ${vtctl_server}:${vtctl_port} ReparentShard -force ${keyspace}/0 ${cell}-0000000100",
    unless  => "vtctlclient -server ${vtctl_server}:${vtctl_port} ListAllTablets ${cell} | grep master"
  }

}
