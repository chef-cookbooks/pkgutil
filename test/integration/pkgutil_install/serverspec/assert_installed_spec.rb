require_relative '../../../kitchen/data/spec_helper'

describe file('/opt/csw/bin/pkgutil') do
  it { should be_file }
end

describe file('/usr/sbin/pkgutil') do
  it { should be_linked_to('/opt/csw/bin/pkgutil') }
end
