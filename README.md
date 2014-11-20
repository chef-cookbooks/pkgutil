pkgutil Cookbook
================

[![Build Status](http://img.shields.io/travis/opscode-cookbooks/pkgutil.svg)][travis]

[travis]: http://travis-ci.org/opscode-cookbooks/pkgutil

This project is managed by the CHEF Release Engineering team. For more information on the Release Engineering team's contribution, triage, and release process, please consult the [CHEF Release Engineering OSS Management Guide](https://docs.google.com/a/opscode.com/document/d/1oJB0vZb_3bl7_ZU2YMDBkMFdL-EWplW1BJv_FXTUOzg/edit).

Requirements
------------

- Chef 11 or higher
- **Ruby 1.9.3 or higher**

Recipes
-------

### opencsw
Configures the local the local pkgutil installation to point at the  Open Community Software Project (OpenCSW) package repository. The optional cryptographic verification will also be enabled for the repository.

Resources/Providers
-------------------

### package

This cookbook provides a package provider which will install/remove packages using `pkgutil`. This becomes the default provider for package if your platform is `solaris2`.

#### Examples

```ruby
package 'vim' do
  action :install
end

package 'vim' do
  provider Chef::Provider::Package::Pkgutil
end
```

### pkgutil_repository

This resource provides an easy way to manage pkgutil repositories. Default action is `:add` which enables the repository. Use `:remove` to disable a repository.

The `pkgutil_repository` resource has the following attributes:

| Attribute         | Description
| ----------------- | -----------
| `mirror`          | mirror to use for downloads (defaults to `http://mirror.opencsw.org/opencsw`)
| `channel`         | also called 'directories', see https://mirror.opencsw.org/opencsw/ for more
| `verification`    | verify the catalog and each package using PGP
| `gpg_homedir`     | path to the gpg directory (defaults to `/var/opt/csw/pki`)
| `pkgadd_options`  | additional options to use for underlying pkgadd commands
| `allow_noncsw`    | support non-CSW packages

This resource will also ensure `pkgutil` and any required public keys are installed!

Testing
-------

You can run the tests in this cookbook using Rake:

```text
rake integration              # Run Test Kitchen integration tests
rake spec                     # Run ChefSpec examples
rake style                    # Run all style checks
rake style:chef               # Lint Chef cookbooks
rake style:ruby               # Run Ruby style checks
rake style:ruby:auto_correct  # Auto-correct RuboCop offenses
rake travis:ci                # Run tests on Travis
```

License & Authors
-----------------

- Author: Martha Greenberg (<marthag@wix.com>)
- Author: Yvonne Lam (<yvonne@getchef.com>)
- Author: Seth Chisamore (<schisamo@getchef.com>)

```text
Copyright 2012-2014, Chef Software, Inc. (<legal@getchef.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
