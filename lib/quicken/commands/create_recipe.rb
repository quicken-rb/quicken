# frozen_string_literal: true

require 'simple_command'
require 'quicken'

module Quicken
  module Commands
    class CreateRecipe
      include Quicken::Helpers::File
      include Quicken::Helpers::Template
      prepend SimpleCommand

      DEFAULT_CONTENT = <<~YAML
        ---
        - echo: Generating project <%= project_name %>

        - readme:
            project_name: <%= project_name %>
            author_name: <%= author_name %>
            <%= "author_email: \#{author_email}" if author_email.present? %>
            <%= "description: \#{description}" if description.present? %>
        - license: <%= license %>
      YAML

      def initialize path:, variables:, empty: false
        @path = path
        @empty = empty
        @variables = variables
        parse DEFAULT_CONTENT
      end

      def call
        content = @empty ? '' : compile(@variables)
        outcome = write_file @path, content
        errors.add(outcome, "could not create file #{@path}") unless outcome == :file_written
      end
    end
  end
end
