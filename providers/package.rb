
def load_current_resource
  @pkgutil = Chef::Resource::PkgutilPackage.new(new_resource.name)
  @pkgutil.name(new_resource.name)
  @pkgutil.pkginfo_name(pkginfo_name?)
  Chef::Log.debug("Checking for pkgutil_package #{new_resource.pkginfo_name}")
  @pkgutil.installed(installed?)
end

action :install do
  unless @pkgutil.installed
    do_install
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  if @pkgutil.installed
    system("pkgutil -y -r #{@pkgutil.name}")
    new_resource.updated_by_last_action(true)
  end
end

action :upgrade do
  if @pkgutil.installed 
    if needs_upgrade?
      system("pkgutil -y -u #{@pkgutil.name}")
      new_resource.updated_by_last_action(true)
    end
  else
    do_install    
  end
end

private

def do_install
  system("pkgutil -y -i #{@pkgutil.name}")
  new_resource.updated_by_last_action(true)
end

def installed?
  system("pkginfo -q -l #{@pkgutil.pkginfo_name}")
end

def pkginfo_name?
  Chef::Log.debug("trying to get solaris package name for #{@pkgutil.name}")
  output = %x(pkgutil -a #{@pkgutil.name})
  output.split("\n").each do |line|
    info = line.split
    if info[0] == @pkgutil.name
      return info[1]
    end
  end
end



def needs_upgrade?
  Chef::Log.debug("trying to get version info for #{@pkgutil.name}")
  output = %x(pkgutil -c #{@pkgutil.pkginfo_name})
  output.split("\n").each do |line|
    info = line.split
    if info[0] == @pkgutil.pkginfo_name 
      if info[2] == "SAME"
        return false
      else
        return true
      end
    end
  end
end
