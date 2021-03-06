#
# Copyright:: 2014-2019, Chef Software, Inc.
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

property :mirror,  String, default: 'http://mirror.opencsw.org/opencsw'
property :channel, String, equal_to: %w(unstable testing stable allpkgs), default: 'stable'
property :verification, [true, false], default: false
property :gpg_homedir, String, default: '/var/opt/csw/pki'
property :pkgadd_options, String
property :allow_noncsw, [true, false], default: false

DEFAULT_PKGUTIL_CONF = '/etc/opt/csw/pkgutil.conf'.freeze

def load_current_resource
  ensure_pkgutil_installed!
  ensure_verification_enabled! if new_resource.verification
end

action(:add) do
  converge_by("Add #{new_resource}") do
    template DEFAULT_PKGUTIL_CONF do
      source 'pkgutil.conf.erb'
      variables new_resource.to_hash
    end
  end
end

action(:remove) do
  if ::File.exist?(DEFAULT_PKGUTIL_CONF)
    converge_by("Remove #{new_resource}") do
      Chef::Log.info "Removing #{new_resource.name} repository from `#{DEFAULT_PKGUTIL_CONF}'"
      file DEFAULT_PKGUTIL_CONF do
        action :delete
      end
    end
  end
end

action_class do
  #
  # Idempotently install the `pkgutil` utility.
  #
  def ensure_pkgutil_installed!
    node.run_state[:pkgutil_installed] ||= begin
      pkgutil_path = ::File.join(Chef::Config[:file_cache_path], 'pkgutil.pkg')

      remote_file pkgutil_path do
        source 'http://mirror.opencsw.org/opencsw/pkgutil.pkg'
      end

      execute "pkgadd -d #{pkgutil_path} all" do
        not_if 'pkginfo -l CSWpkgutil'
      end

      true
    end
  end

  #
  # Idempotently install the `cswpki` and import the keys.
  #
  def ensure_verification_enabled!
    node.run_state[:verification_enabled] ||= begin
      execute 'enable-cryptographic-verification' do
        command <<-EOH.gsub(/ ^{12}/, '')
          pkgutil -y -i cswpki
          cswpki --import --force
        EOH
        not_if 'gpg --homedir=/var/opt/csw/pki  --list-keys | grep board@opencsw.org'
      end

      true
    end
  end
end
