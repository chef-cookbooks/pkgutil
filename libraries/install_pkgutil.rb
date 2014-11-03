#
# Copyright 2014, Chef Software, Inc.
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

class Chef
  class Resource::InstallPkgutil < Resource::LWRPBase
    self.resource_name = :install_pkgutil
    provides :install_pkgutil

    actions :install
    default_action :install
    attribute :mirror,  kind_of: String, default: 'http://mirror.opencsw.org/opencsw'
    attribute :catalog, kind_of: String, default: 'stable'
    attribute :cryptographic_verification, kind_of: [TrueClass, FalseClass], default: true
    attribute :manage_opencsw_gpg_keys, kind_of: [TrueClass, FalseClass], default: true
  end

  class Provider::InstallPkgutil < Provider::LWRPBase
    include Pkgutil::Helper

    def whyrun_supported?
      true
    end

    action(:install) do
      # @TODO: a more correct idempotence check.
      if installed?
        Chef::Log.info("#{new_resource} is installed, skipping")
      else
        converge_by("Install #{new_resource}") do
          install
          setup_verification if new_resource.cryptographic_verification == true
          manage_keys if new_resource.manage_opencsw_gpg_keys == true
        end
      end
    end

    protected

    def installed?
      ::File.exists?("/usr/sbin/pkgutil")
    end

    def install
      configure_pkgutil
      install_package
      create_symlink
      configure_mirror
    end

    def setup_verification
      Chef::Log.info("Installling cswpki with pkgutil")
      pkgutil('-y -i cswpki')
      import_opencsw_pubkey
      enable_verification
    end

    def manage_keys
      command = <<-EOH.gsub(/^ {8}/, '')
        echo "pki_auto=yes" >> /etc/opt/csw/csw.conf
      EOH
      execute_command("Set up automatic management of OpenCSW keys", command)
    end

    private

    def configure_pkgutil
      command = <<-EOH.gsub(/^ {8}/, '')
        echo "action=nocheck\nsetuid=nocheck" > pkgutil.admin
      EOH
      execute_command('Configure pkgutil', command)
    end

    def install_package
      command = <<-EOH.gsub(/^ {8}/, '')
        echo "all" | pkgadd -n -d http://get.opencsw.org/#{new_resource.catalog} -a pkgutil.admin
      EOH
      execute_command("install #{new_resource}", command)
    end

    def create_symlink
      link = Resource::Link.new("Create link to OpenCSW pkgutil", run_context)
      link.owner('root')
      link.target_file('/usr/sbin/pkgutil')
      link.to('/opt/csw/bin/pkgutil')
      link.run_action(:create)
    end

    def configure_mirror
      command = <<-EOH.gsub(/^ {8}/, '')
        echo "mirror=#{new_resource.mirror}/#{new_resource.catalog}" >> /etc/opt/csw/pkgutil.conf
      EOH
      execute_command("Configure OpenCSW mirror", command)
    end

    def import_opencsw_pubkey
      command = <<-EOH.gsub(/^ {8}/, '')
        cswpki --import --force
      EOH
      execute_command("Import OpenCSW pubkey", command)
    end

    def enable_verification
      command = <<-EOH.gsub(/^ {8}/, '')
        echo "use_gpg=true" >> /etc/opt/csw/pkgutil.conf
        echo "use_md5=true" >> /etc/opt/csw/pkgutil.conf
      EOH
      execute_command("Enable cryptographic verification", command)
    end

    #
    # Create an execute resource and run it.
    # Is there a compelling reason to use execute resources here instead of mixlib-shellout?
    #
    def execute_command(description, command)
      execute = Resource::Execute.new(description, run_context)
      execute.user('root')
      execute.cwd('/tmp')
      execute.command(command)
      execute.run_action(:run)
    end
  end
end
