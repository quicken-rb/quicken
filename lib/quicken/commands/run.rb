require 'simple_command'
require 'quicken/core/autoloader'

module Quicken
  module Command
    class Run
      prepend SimpleCommand

      def initialize recipe_path
        @parser = Quicken::Parser.new recipe_path
      end

      def call
        config = @parser.parse
        @runner = Quicken::Runner.new config
        LOGGER.debug(:runner) { "Running with config #{config.inspect}" }
        @runner.run
      rescue Errno::ENOENT => e
        errors.add(:file_not_found, e.message)
      rescue StandardError => e
        errors.add(:unknown_error, e.class.name)
        errors.add(:unknown_error, e.message)
      end
    end
  end
end