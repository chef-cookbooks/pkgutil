# Cookbook Name:: pkgutil
# Recipe:: default
# Author: Cam Cope <ccope@brightcove.com>
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

fail "Platform #{node['platform']} is not supported by pkgutil" unless platform?("solaris2")

bash "install_opencsw_repo" do
  user "root"
  cwd "/tmp"
  code <<-EOF
  echo "action=nocheck\nsetuid=nocheck" > pkgutil.admin
  echo "all" | pkgadd -n -d http://get.opencsw.org/#{node["opencsw"]["release"]} -a pkgutil.admin
  ln -s /opt/csw/bin/pkgutil /usr/sbin/pkgutil
  echo "mirror=#{node["opencsw"]["mirror"]}/#{node["opencsw"]["release"]}" >> /etc/opt/csw/pkgutil.conf
  pkgutil -U
  echo "pki_auto=yes" >> /etc/opt/csw/csw.conf
  pkgutil -y -i cswpki
  echo "use_gpg=true" >> /etc/opt/csw/pkgutil.conf
  echo "use_md5=true" >> /etc/opt/csw/pkgutil.conf
  EOF
  not_if { File.exists?("/usr/sbin/pkgutil") }
end

%w(pubring.gpg trustdb.gpg secring.gpg).each do |afile|
  cookbook_file "/var/opt/csw/pki/#{afile}" do
    source afile
    owner "root"
    group "other"
    mode "0600"
  end
end

