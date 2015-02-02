require 'spec_helper'
describe 'vitess' do

  context 'with defaults for all parameters' do
    it { should contain_class('vitess') }
  end
end
