name             'pkgutil'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache 2.0'
description      'Manages Solaris pkgutil packages'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.3'

supports 'solaris2'

source_url 'https://github.com/chef-cookbooks/pkgutil' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/pkgutil/issues' if respond_to?(:issues_url)
