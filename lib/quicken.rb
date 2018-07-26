# frozen_string_literal: true

require 'thor'
require 'quicken/version'

module Quicken
  class App < Thor
    option :version, type: :boolean, aliases: [:v]
    desc 'qk', 'Quicken base command'

    def default
      if options.version?
        puts "Quicken #{Quicken::VERSION}"
      else
        help
      end

    end

    default_command :default
  end
end
