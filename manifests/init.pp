#
# Class vitess
#   Setup vitess
#

class vitess {

  ##
  # TODO: most of the code here will be removed after making a package.
  # Install all prerequisite packages
  ##
  $prereq_packages = ['make', 'automake', 'libtool' ,'memcached' ,'python-dev' ,
                      'libssl-dev','g++','mercurial','golang',
                      'libmariadbclient-dev','git' ,'pkg-config' ,'bison',
                      'curl','libzookeeper-mt-dev']

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
  # Base config directory
  ##
  file {'/etc/vitess/':
    ensure => directory,
  }

  file {'/usr/local/share/vitess':
    ensure => directory,
  }
}
