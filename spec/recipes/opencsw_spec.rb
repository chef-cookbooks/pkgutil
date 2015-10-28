require 'spec_helper'

describe 'pkgutil::opencsw' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'adds the OpenCSW repository' do
    expect(chef_run).to add_pkgutil_repository('OpenCSW').with(
      mirror: 'http://mirror.opencsw.org/opencsw',
      channel: 'stable',
      verification: true
    )
  end

  it 'updates the package catalog' do
    expect(chef_run).to run_execute('pkgutil-update').with(
      command: 'pkgutil -U'
    )
  end
end
