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
        include Chef::Mixin::ShellOut

        def define_resource_requirements
          super
          Chef::Log.debug('Pkgutil: define_resource_requirements')
          requirements.assert(:install) do |a|
            a.assertion { !new_resource.source }
            a.failure_message Chef::Exceptions::Package, 'We currently do not support install from source.'
          end
        end

        def load_current_resource
          Chef::Log.debug('Pkgutil: load_current_resource')
          @current_resource = Chef::Resource::Package.new(new_resource.name)
          @current_resource.package_name(new_resource.package_name)
          @current_resource.version(nil)

          output = pkgutil("--parse -A #{new_resource.package_name}")

          # Query for current installed version
          match = output.match(/^#{pkg_name}\s(.+)\sSAME$/)
          if match
            version = match[1].strip
            @current_resource.version(version)
          end

          @current_resource
        end

        def candidate_version
          Chef::Log.debug('Pkgutil: candidate_version')
          return @candidate_version if @candidate_version
          output = pkgutil("--parse -a #{new_resource.package_name}")
          match = output.match(/^#{catalog_name}\s+#{pkg_name}\s(.+)\s\d+$/)

          if match
            version = match[1].strip
            @candidate_version = version
            new_resource.version(version)
            Chef::Log.info("#{new_resource} setting install candidate version to #{@candidate_version}")
          end

          @candidate_version
        end

        def install_package(name, version)
          Chef::Log.debug('Pkgutil: install_package')
          if installed?
            Chef::Log.info("The package #{name} version #{version} is already installed. Skipping.")
          else
            Chef::Log.info("Installing package #{name} at version #{version}")
            pkgutil("-y -i #{pkg_name}-#{version}")
          end
        end

        def remove_package(name, _version)
          Chef::Log.debug('Pkgutil: remove_package')
          if installed?
            Chef::Log.info("Removing package #{name}.")
            pkgutil("-y --parse -r #{pkg_name}")
          else
            Chef::Log.info("Package #{name} is not installed. Skipping.")
          end
        end

        private

        #
        # Run a pkgutil command
        #
        def pkgutil(command)
          Chef::Log.debug("Running command \"pkgutil #{command}\"")
          shell_out!("pkgutil #{command}").stdout
        end

        #
        # http://www.opencsw.org/manual/for-maintainers/package-naming.html
        #
        def catalog_name
          @catalog_name ||= begin
            name = new_resource.package_name
            # escape plus signs
            name.gsub('+', '\\\+')
          end
        end

        #
        # http://www.opencsw.org/manual/for-maintainers/package-naming.html
        #
        def pkg_name
          @pkg_name ||= begin
            name = catalog_name
            # CSW uses underscores in short package names and dashes in official package names.
            name.tr!('_', '-')
            # Prefix with `CSW`
            'CSW' << name
          end
        end

        def installed?
          output = pkgutil("--parse -A #{new_resource.package_name}")

          if output == ''
            raise("The package #{new_resource.package_name} does not exist in the catalog.")
          end
          output.each_line do |line|
            if new_resource.version.nil? && line.match(/^#{pkg_name}\s.+\sSAME$/)
              Chef::Log.info('Package is installed, no desired version specified.')
              return true
            elsif line =~ /^#{pkg_name}\s#{new_resource.version}\sSAME$/
              Chef::Log.info('Required version of package is installed.')
              return true
            elsif line =~ /^#{pkg_name}\s#{new_resource.version}\snot installed$/
              Chef::Log.info('Required package or version is not installed.')
              next
            end
          end
          false
        end

        def safe(string)
          string.gsub('+', '\\\+')
        end
      end
    end
  end
end
