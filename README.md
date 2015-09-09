pgkutil cookbook
================
[![Build Status](https://travis-ci.org/chef-cookbooks/pgkutil.svg?branch=master)](http://travis-ci.org/chef-cookbooks/pgkutil)
[![Cookbook Version](https://img.shields.io/cookbook/v/pgkutil.svg)](https://supermarket.chef.io/cookbooks/pgkutil)

Lightweight resource and provider to manage pkgutil packages for Solaris

Requirements
============

Solaris, OpenCSW pkgutil already installed.

Attributes
==========

Usage
=====

In the cookbook that has the pkgutil_package resources, add a
dependency on the pkgutil cookbook in your metadata.rb file, like
this:

    depends "pkgutil"

Then use the resources as follows:

    pkgutil_package "vim"

Or:

    pkgutil_package "vim" do 
      action :install
    end

    pkgutil_package "top" do
      action :upgrade
    end

    pkgutil_package "less" do 
      action :remove
    end


License & Authors
-----------------
```text
Copyright 2009-2015, Chef Software, Inc.

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
