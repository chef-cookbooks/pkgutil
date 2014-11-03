#
# Copyright:: Copyright (c) 2014 Chef, Inc.
# License:: Apache License, Version 2.0
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
require 'chef/provider/package'
require 'chef/resource/package'
require 'chef/platform'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Package
      class Pkgutil < Chef::Provider::Package
        require_relative '_pkgutil_helper'
        include Chef::Mixin::ShellOut
        include ::Pkgutil::Helper
        # based on 11-stable

        def define_resource_requirements
          super
          Chef::Log.debug("Pkgutil: define_resource_requirements")
          requirements.assert(:install) do |a|
            a.assertion { !@new_resource.source }
            a.failure_message Chef::Exceptions::Package, "We currently do not support install from source."
          end
        end

        def load_current_resource
          Chef::Log.info("Pkgutil:  load_current_resource")
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @new_resource.version(nil)

          unless @current_resource.version.nil?
            @current_resource.version(nil)
          end

          @current_resource
        end

        def candidate_version
          Chef::Log.debug("Pkgutil:  candidate_version")
          return @candidate_version if @candidate_version
          output = pkgutil("--parse -a #{@new_resource.package_name}")
          output.each_line do |line|
            if line.match(/^#{new_resource.package_name}\sCSW\w+\s(.+)+\s\d+$/)
              @candidate_version = $1
              @new_resource.version($1)
              Chef::Log.info("#{@new_resource} setting install candidate version to #{@candidate_version}")
            end
          end
          @candidate_version
        end

        def install_package(name, version)
          Chef::Log.debug("Pkgutil:  install_package")
          if installed?
            Chef::Log.info("The package #{new_resource.package_name} version #{new_resource.version} is already installed.  Skipping.")
          elsif
            Chef::Log.info("Installing package #{@new_resource.package_name} at version #{@new_resource.version}")
            pkgutil("-y -i CSW#{@new_resource.package_name}-#{@new_resource.version}")
          end
        end

        def remove_package(name, version)
          Chef::Log.debug("Pkgutil:  remove_package")
          if installed?
            Chef::Log.info("Removing package #{@new_resource.package_name}.")
            pkgutil("-y --parse -r CSW#{@new_resource.package_name}-#{@new_resource.version}")
          elsif
            Chef::Log.info("Package #{@new_resource.package_name} version #{@new_resource.version} not installed.  Skipping.")
          end
        end

        private

        def installed?
          output = pkgutil("--parse -A #{new_resource.package_name}")

          if output == ''
            fail("The package #{new_resource.package_name} does not exist in the catalog.")
          end
          output.each_line do |line|
            if line.match(/^CSW#{@new_resource.package_name}\s+#{@new_resource.version}\s+SAME$/)
              Chef::Log.info("Required version of package is installed.")
              return true
            elsif line.match(/^CSW#{@new_resource.package_name}\s+#{@new_resource.version}\s+not installed$/)
              Chef::Log.info("Required package or version is not installed.")
              next
            end
          end
          false
        end
      end
    end
  end
end

Chef::Platform.set :platform => :solaris2, :resource => :package, :provider => Chef::Provider::Package::Pkgutil


