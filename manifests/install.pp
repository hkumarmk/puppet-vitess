#
# Class vitess::install
#   Install vitess
#

class vitess::install {
# required for vitess
  package { 'golang':
    ensure => present,
  }

  package { 'libmariadbclient-dev':
    ensure => present,
  }

  ensure_packages ( ['make', 'automake', 'libtool' ,'memcached' ,'python-dev' ,'libssl-dev' ,'g++' ,'mercurial' 
                      ,'git' ,'pkg-config' ,'bison' ,'curl','libzookeeper-mt-dev'] )

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
  }

  exec { 'install_vitess':
    command     => '/bin/bash -x /root/install_vitess.sh',
    logoutput   => true,
    refreshonly => true,
  }

}
