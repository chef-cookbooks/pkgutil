# Cookbook Name:: pkgutil
# Recipe:: default
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

# Update the package catalog
execute "update_catalog" do
  user 'root'
  cwd  '/tmp'
  command 'pkgutil -U'
  action :nothing
end

install_pkgutil 'pkgutil' do
  notifies :run, 'execute[update_catalog]', :immediately
end
