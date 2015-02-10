#
# Class vitess::mysql
#
class vitess::mysql (
  $keyspace = ['test_keyspace'],
) {

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

  ##
  # link mysql command to /usr/local - this is a workaround for now.
  ##
  file {'/usr/local/bin/mysql':
    ensure  => link,
    target  => '/usr/bin/mysql',
    require => Package['mariadb-server'],
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

  mysql_database { "vt_${keyspace}":
    ensure   => present,
    charset  => 'utf8',
    provider => 'mysql',
  }

  mysql_database { '_vt':
    ensure   => present,
    charset  => 'utf8',
    provider => 'mysql',
  }

  exec {'create_table__vt_replication_log':
    command  => "mysql -e '
      CREATE TABLE _vt.replication_log ( time_created_ns bigint primary key, note varchar(255));
      CREATE TABLE _vt.reparent_log ( time_created_ns bigint primary key,
        last_position varchar(255), new_addr varchar(255), new_position varchar(255),
        wait_position varchar(255), index (last_position));'",
    unless  => "mysql -e \"select count(*) from information_schema.tables where
        (table_name='replication_log' or table_name='reparent_log') and
        table_schema='_vt';\" | grep -v count | grep 2",
    require => Mysql_database['_vt'],
  }
}
