require 'serverspec'

# Required by serverspec
set :backend, :exec

RSpec.configure do |config|
  config.before(:all) do
    config.path = '/sbin:/usr/local/sbin:/bin'
  end
end
