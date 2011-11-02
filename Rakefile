
# Installs required rubygems, probably requires root permissions
task :gems do
  require 'rubygems/dependency_installer'
  installer = Gem::DependencyInstaller.new

  %w{rubytree}.each do |gem|
    installer.install gem
  end
end
