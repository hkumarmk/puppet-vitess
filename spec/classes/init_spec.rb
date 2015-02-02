require 'spec_helper'
describe 'vitess' do

  context 'with defaults' do
    let (:package_list) {['make', 'automake', 'libtool','memcached',
                          'python-dev','libssl-dev','g++','mercurial','golang','libmariadbclient-dev','git',
                          'pkg-config' ,'bison','curl','libzookeeper-mt-dev']}
    it do
      package_list.each do |pkg|
        should contain_package(pkg)
      end
      should contain_User('vitess')
      should contain_file('/var/lib/vitess')
      should contain_file('/var/log/vitess')
      should contain_file('/etc/vitess/')
      should contain_file('/usr/local/share/vitess')
    end
  end
end
