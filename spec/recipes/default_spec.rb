require 'spec_helper'

describe 'pkgutil::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(platform: 'solaris2', version: '5.11')
    .converge(described_recipe)
  end

  it 'converges the node' do
    chef_run
  end
end
