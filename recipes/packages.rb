node['auto-updater']['packages'].each do |package|
  package package.name do
    package_name package.package_name if package.package_name
    version package.version if package.version
    arch package.arch if package.arch
  end
end
