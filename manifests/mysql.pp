#
# Class vitess::mysql
#
class vitess::mysql {

  ##
  # Just a workaround for now, need to move to right manifests
  ##

  ensure_packages('mariadb-server')

  file {'/etc/mysql/my.cnf':
    source  => "puppet:///modules/${module_name}/my.cnf",
    notify  => Service['mysql'],
    require => Package['mariadb-server'],
  }

  file {'/var/lib/mysql/logs':
    ensure => directory,
    owner  => 'mysql',
    before => Service['mysql'],
  }

  service {'mysql':
    ensure => running,
  }

  Service['mysql'] -> Mysql_user<||>
  Service['mysql'] -> Mysql_grant<||>

  mysql_user {'vt_repl@%':
    ensure   => present,
    provider => 'mysql',
  }

  mysql_grant {'vt_repl@%/*.*':
    privileges => ['REPLICATION SLAVE'],
    provider   => 'mysql',
    user       => 'vt_repl@%',
    table      => '*.*',
  }

  mysql_user {'vt_app@localhost':
    ensure   => present,
    provider => 'mysql',
  }

  mysql_grant {'vt_app@localhost/*.*':
    privileges => ['SELECT','INSERT','UPDATE','DELETE','CREATE','DROP',
                    'RELOAD','PROCESS','FILE','REFERENCES','INDEX',
                    'ALTER','SHOW DATABASES','CREATE TEMPORARY TABLES',
                    'LOCK TABLES','EXECUTE','REPLICATION SLAVE',
                    'REPLICATION CLIENT','CREATE VIEW','SHOW VIEW',
                    'CREATE ROUTINE','ALTER ROUTINE','CREATE USER',
                    'EVENT','TRIGGER'],
    provider   => 'mysql',
    user       => 'vt_app@localhost',
    table      => '*.*',
  }

  mysql_user {'vt_dba@localhost':
    ensure   => present,
    provider => 'mysql',
  }

  mysql_grant {'vt_dba@localhost/*.*':
    privileges => ['ALL'],
    provider   => 'mysql',
    user       => 'vt_dba@localhost',
    table      => '*.*',
  }

  mysql_user {'vt_filtered@localhost':
    ensure   => present,
    provider => 'mysql',
  }

  mysql_grant {'vt_filtered@localhost/*.*':
    privileges => ['SELECT','INSERT','UPDATE','DELETE','CREATE','DROP',
                    'RELOAD','PROCESS','FILE','REFERENCES','INDEX',
                    'ALTER','SHOW DATABASES','CREATE TEMPORARY TABLES',
                    'LOCK TABLES','EXECUTE','REPLICATION SLAVE',
                    'REPLICATION CLIENT','CREATE VIEW','SHOW VIEW',
                    'CREATE ROUTINE','ALTER ROUTINE','CREATE USER',
                    'EVENT','TRIGGER'],
    provider   => 'mysql',
    user       => 'vt_filtered@localhost',
    table      => '*.*',
  }

  mysql_database { 'vt_test_keyspace':
    ensure   => present,
    charset  => 'utf8',
    provider => 'mysql',
  }

}
