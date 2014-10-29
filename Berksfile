def fixture(name)
  cookbook "pkgutil_#{name}", path: "test/fixtures/cookbooks/pkgutil_#{name}"
end

source 'https://api.berkshelf.com'
metadata

group :integration do
  fixture 'install'
end
