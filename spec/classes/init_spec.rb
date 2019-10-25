require 'spec_helper'
describe 'scom' do
  context 'with default values for all parameters' do
    it { should contain_class('scom') }
  end
end
