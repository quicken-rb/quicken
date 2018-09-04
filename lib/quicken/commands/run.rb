# frozen_string_literal: true

require 'simple_command'
require 'quicken'

module Quicken
  module Commands
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
      rescue Quicken::Error => e
        errors.add(e.error_name, e.message)
      end
    end
  end
end
