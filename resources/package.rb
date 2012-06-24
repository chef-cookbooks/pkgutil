actions :install, :remove, :upgrade

attribute :name, :kind_of => String
attribute :pkginfo_name,:kind_of => String, :default => nil
attribute :installed, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :install
end
