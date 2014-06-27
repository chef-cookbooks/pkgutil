
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
    cmd = Mixlib::ShellOut.new("pkgutil -y -r #{@pkgutil.name}")
    cmd.run_command
    cmd.error!
    new_resource.updated_by_last_action(true)
  end
end

action :upgrade do
  if @pkgutil.installed 
    if needs_upgrade?
      cmd = Mixlib::ShellOut.new("pkgutil -y -u #{@pkgutil.name}")
      cmd.run_command
      cmd.error!
      new_resource.updated_by_last_action(true)
    end
  else
    do_install    
    new_resource.updated_by_last_action(true)
  end
end

private

def do_install
  cmd = Mixlib::ShellOut.new("pkgutil -y -i #{@pkgutil.name}")
  cmd.run_command
  cmd.error!
end

def installed?
  cmd = Mixlib::ShellOut.new("pkginfo -q -l #{@pkgutil.pkginfo_name}")
  cmd.run_command
end

def pkginfo_name?
  Chef::Log.debug("trying to get solaris package name for #{@pkgutil.name}")
  cmd = Mixlib::ShellOut.new("pkgutil -a #{@pkgutil.name}")
  cmd.run_command
  output = cmd.stdout
  output.split("\n").each do |line|
    info = line.split
    if info[0] == @pkgutil.name
      return info[1]
    end
  end
end



def needs_upgrade?
  Chef::Log.debug("trying to get version info for #{@pkgutil.name}")
  cmd = Mixlib::ShellOut.new("pkgutil -c #{@pkgutil.pkginfo_name}")
  cmd.run_command
  output = cmd.stdout
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
