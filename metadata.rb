name             'pkgutil'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache-2.0'
description      'Manages Solaris pkgutil packages'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.0'

supports 'solaris2'

source_url 'https://github.com/chef-cookbooks/pkgutil'
issues_url 'https://github.com/chef-cookbooks/pkgutil/issues'
chef_version '>= 12.7' if respond_to?(:chef_version)
