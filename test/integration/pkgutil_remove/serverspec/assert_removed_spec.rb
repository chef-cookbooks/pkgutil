require_relative '../../../kitchen/data/spec_helper'

# serverspec's `package` resource uses the `pkg` command.
# https://github.com/serverspec/specinfra/tree/master/lib/specinfra/command/solaris/base
# `pkg` is not installed on solaris 10.11, hence the test below is not useful.
# Once we have test-kitchen and busser working on solaris, we should look into adding
# pkgutil support to the `package` resource or creating a custom serverspec type.
#
# describe package('vim') do
#  it { should not_be_installed }
# end

describe command('pkgutil --parse -A vim') do
  its(:stdout) { should match(/^CSWvim\s+.*\snot\sinstalled$/) }
end

describe command('pkgutil --parse -A znc') do
  its(:stdout) { should match(/^CSWznc\s+.*\snot\sinstalled$/) }
end
