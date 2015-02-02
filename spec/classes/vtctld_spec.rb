require 'spec_helper'
describe 'vitess::vtctld' do

  context 'with defaults' do
    it do
      should contain_file('/etc/vitess/zk-client-conf.json').with({
        'ensure'  => 'file',
        'notify'  => 'Service[vtctld]'
      })
      should contain_file('/etc/init/vtctld.conf').with({
        'ensure' => 'file',
        'source' => "puppet:///modules/vitess/init/vtctld.conf",
      })

      should contain_service('vtctld').with_ensure('running')
      should contain_file('/usr/local/share/vitess/vtctld').with({
          'ensure'  => 'directory',
          'source'  => '/usr/local/src/github.com/youtube/vitess/go/cmd/vtctld',
          'recurse' => true,
      })
    end
  end
end
