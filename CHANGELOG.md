pkgutil Cookbook CHANGELOG
======================
This file is used to list changes made in each version of the pkgutil cookbook.

## 3.0.0 (2017-11-01)

- Test with Local Delivery instead of Rake
- Update Apache license string in metadata
- Convert repository to a custom resource which requires Chef 12.7+
- Load current resource in a Chef 13 compatible way
- Updated providers to Chef 13 compatible syntax

## 2.1.0 (2017-01-18)

- Fix - handle "+" in package name
- Update Github PR template

## 2.0.0 (2016-09-16)

- Enable use_inline_resources
- Testing framework updates
- Format readme and remove release engineering blurb
- Require Chef 12.1

## v1.0.0 (2016-04-27)

- Converted the pkgutil_package into a true package provider that runs as the default on Solaris systems
- Added Chefspec tests
- Added Test Kitchen testing
- Add rubocop config and resolved warnings
- Added Gemfile with test deps
- Fixed Readme badges
- Added a chefignore file
- Added testing and contributing docs
- Added this changelog
- Added license file and license information in the readme
- Added name to the metadata
- Added source_url and issues_url to the metadata
- Added maintainers files and rake task to generate the markdown
- Fixed typos in the readme
- Added a .foodcritic file to disable FC048 and FC001
- Updated Travis CI config to test with Chef DK
