if defined?(ChefSpec)
  def add_pkgutil_repository(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:pkgutil_repository, :add, resource_name)
  end

  def remove_pkgutil_repository(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:pkgutil_repository, :remove, resource_name)
  end
end
