#
# Class vitess
#   Setup vitess
#

class vitess (
  $zk_hosts = ['localhost'],
  $zk_port = 21811,
) {

  ##
  # TODO: most of the code here will be removed after making a package.
  # Install all prerequisite packages
  ##
  $prereq_packages = ['mariadb-server','make', 'automake', 'libtool' ,'memcached' ,'python-dev' ,
                      'libssl-dev','g++','mercurial','golang',
                      'libmariadbclient-dev','git' ,'pkg-config' ,'bison',
                      'curl','libzookeeper-mt-dev']

  include java

  ensure_packages($prereq_packages)

  vcsrepo { '/usr/local/src/github.com/youtube/vitess' :
    ensure   => present,
    provider => git,
    source   => 'https://github.com/youtube/vitess.git',
  } ->
  file { '/root/install_vitess.sh':
    content =>
'#!/bin/bash
cd /usr/local/src/github.com/youtube/vitess
export MYSQL_FLAVOR=MariaDB
./bootstrap.sh
. ./dev.env
make build',
    mode    => '755',
    notify  => Exec['install_vitess'],
    require => Package[$prereq_packages],
  }

  exec { 'install_vitess':
    command     => '/bin/bash -x /root/install_vitess.sh',
    logoutput   => true,
    refreshonly => true,
  }

  ##
  # create user vitess, create data directory
  ##
  user {'vitess':
    ensure => present,
    home   => '/var/lib/vitess',
    shell  => '/bin/bash',
  }

  file { '/var/lib/vitess':
    ensure  => directory,
    owner   => 'vitess',
    require => User['vitess'],
  }

  file { '/var/log/vitess':
    ensure  => directory,
    owner   => 'vitess',
    require => User['vitess'],
  }

  ##
  # zk-client-conf.json - zookeeper client configuration
  ##
  file {'/etc/zookeeper':
    ensure => directory,
  }

  file {'/etc/zookeeper/zk_client.json':
    ensure  => file,
    content => template("${module_name}/zk-client-conf.json.erb"),
    require => File['/etc/zookeeper'],
  }

  ##
  # Base config directory
  ##
  file {'/etc/vitess/':
    ensure => directory,
  }

  file {'/usr/local/share/vitess':
    ensure => directory,
  }

  ##
  # For some reason, the zookeeper version coming with ubuntu is not working
  # with vitess, so had to use the version coming with vitess.
  ##

  file { '/etc/init/vtzk.conf':
    ensure  => file,
    source  => "puppet:///modules/${module_name}/init/vtzk.conf",
  }

  file { '/usr/local/bin/zkctl.sh':
    ensure => file,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/zkctl.sh",
  }

  service {'vtzk':
    ensure  => running,
    require => [ File['/etc/init/vtzk.conf'],
                 File['/usr/local/bin/zkctl.sh'],
                 Exec['install_vitess'],
                 Class['java'] ],
  }

}
