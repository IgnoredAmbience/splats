require 'rake/testtask'

# Installs required rubygems, probably requires root permissions
# 'rake gems'
task :gems do
  %w{yard flexmock}.each do |gem|
    if not system "gem install #{gem}"
      system "gem install --user-install #{gem}"
    end
  end
end

# Run tests with 'rake test'
Rake::TestTask.new

begin
  require 'yard'
  # Generate docs with 'rake yard'
  YARD::Rake::YardocTask.new
rescue Exception
end
