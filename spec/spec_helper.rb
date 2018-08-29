require "bundler/setup"
require "quicken"
require "quicken/autoloader"
require 'logger'
require 'pry'


LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::WARN
LOGGER.formatter = proc { |severity, datetime, progname, msg|
  "#{severity} [#{datetime}] - [#{progname.upcase}] #{msg}\n"
}

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
