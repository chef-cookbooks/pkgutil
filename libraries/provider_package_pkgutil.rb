#
# Copyright 2013-2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This implements a minimal `pkgutil` resource and provider.
# We really, really want this to override the existing solaris package provider.

require 'mixlib/shellout'
require 'chef/provider'
require 'chef/provider/package'
require 'chef/resource/package'

class Chef
  class Resource::Pkgutil < Resource::LWRPBase
    self.resource_name = :pkgutil
    provides :pkgutil

    actions :install, :remove
    default_action :install

    attribute :version,               kind_of: String, default: nil
   end
  class Provider::Pkgutil < Provider::LWRPBase
    include ::Pkgutil::Helper

    #
    #
    def load_current_resource
      Chef::Log.info("I AM HERE!")
      unless ::File.exist?('/usr/sbin/pkgutil')
        raise Chef::Exceptions::User, "Could not find binary /usr/sbin/pkgutil for #{new_resource}"
      end

      @current_resource ||= Chef::Resource::Pkgutil.new(new_resource.name)
    end

    action(:install) do
      install_package
    end

    action(:remove) do
      remove_package
    end

    def install_package
      if installed?
        Chef::Log.info("Nothing to do, moving on")
      else
        Chef::Log.info("Not installed, running install")
        do_install
      end
    end

    def remove_package
      if installed?
        pkgutil("-y -r #{new_resource.name}")
      else
        Chef::Log.info("Package not installed, nothing to do.")
      end
    end

    private

    def pkgtil(command)
      shell_out!(%Q(pkgutil #{command})).stdout
    end

    def installed?
      # Is there a better way to get to the package name than prepending CSW to it?
      cmd = Mixlib::ShellOut.new("pkginfo -q -l CSW#{new_resource.name}").run_command
      return false if cmd.exitstatus.eql?(1)
      true
    end

    def do_install
      pkgutil("-y -i #{new_resource.name}")
    end

    # will need to be able to get the current installed version
  end
end

#Chef::Platform.set :platform => :solaris2, :resource => :package, :provider => Chef::Provider::Package::Solaris
