require 'spec_helper'
describe 'releasequeue' do

  context 'with defaults for all parameters' do
    it { should contain_class('releasequeue') }
  end
end
