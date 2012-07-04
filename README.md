[![Build Status](https://secure.travis-ci.org/nathenharvey/pkgutil.png)](http://travis-ci.org/nathenharvey/pkgutil)

Description
==========

Lightweight resource and provider to manage pkgutil packages for Solaris

Requirements
===========

Solaris, OpenCSW pkgutil already installed.

Attributes
=========

Usage
====

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

