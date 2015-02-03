#
# Class vitess::vttablet
#
class vitess::vttablet {

  file { '/etc/init/vttablet.conf':
    ensure => file,
    source => "puppet:///modules/${module_name}/init/vttablet.conf",
  }

  service {'vttablet':
    ensure  => running,
    require => File['/etc/init/vttablet.conf'],
  }

}
