#
# Class vitess::vtgate
#
# Manage vitess management system, vtgate
#
class vitess::vtgate (
) {

  file { '/etc/init/vtgate.conf':
    ensure => file,
    source => "puppet:///modules/${module_name}/init/vtgate.conf",
  }

  service {'vtgate':
    ensure  => running,
    require => File['/etc/init/vtgate.conf'],
  }

}
