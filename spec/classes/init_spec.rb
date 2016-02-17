require 'spec_helper'
describe 'batman' do

  context 'with defaults for all parameters' do
    it { should contain_class('batman') }
  end
end
