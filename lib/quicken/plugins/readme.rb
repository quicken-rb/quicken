# frozen_string_literal: true

require 'quicken/helpers/template'
require 'quicken/helpers/file'

module Quicken
  module Plugins
    class Readme < Quicken::Plugin
      include Quicken::Helpers::File
      include Quicken::Helpers::Template

      def initialize args
        @template = args.delete(:template)
        @force = !!args.delete(:force)
        @variables = args
        parse template
      end

      def call
        LOGGER.info(:readme) { 'Creating README file' }
        LOGGER.debug(:readme) { "Compiling template:\n#{template}" }
        result = compile @variables
        outcome = write_file 'README.md', result, force: @force
        if outcome == :file_exists
          say 'README already present. Skipping...'
        else
          say 'Created README file'
        end
      end

      private

      def template
        @template ||= DEFAULT
      end

      DEFAULT = <<~ERB
        # <%= project_name %>
        ### by <%= author_name %> <<%= author_email %>>
        ---
        <%= description %>
      ERB
    end
  end
end
