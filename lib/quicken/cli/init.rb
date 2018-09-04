# frozen_string_literal: true

require 'fileutils'

module Quicken
  module CLI
    class Init < Thor
      include Thor::Actions

      method_option :empty, type: :boolean, aliases: [:e], default: false
      method_option :output, type: :string, aliases: [:o], default: 'recipe.yml'
      desc 'project', 'Initialize a new recipe file'

      def project name = nil
        variables = {
          project_name: name || ask_required('Project name:'),
          author_name:  ask_required('Author:'),
          author_email: ask('Author email (optional):'),
          description:  ask('Description (optional):'),
          license:      ask('License:', default: 'mit')
        }

        cmd = Quicken::Commands::CreateRecipe.call path: options.output, variables: variables, empty: options.empty
        handle_errors cmd.errors unless cmd.success?
        say "Generated new recipe file in #{options.output}" if cmd.success?
      end

      desc 'plugin NAME', 'Scaffold a new Quicken plugin'

      def plugin name
        say "Creating #{name} plugin", :yellow

        # Invoke via system call because
        # Bundler does not expose a programmatic API
        bundler_done = system "bundle gem quicken-#{name} #{bundler_gem_options}"
        add_plugin_folder name if bundler_done
      end

      default_command :project

      private

      def ask_required message
        answer = ask message
        answer = ask "REQUIRED #{message}"until answer.present?
        answer
      end

      def bundler_gem_options
        @bundler_gem_options ||= '--no-exe --coc --no-ext --no-mit --test=rspec'
      end

      def plugin_file_content name
        @plugin_file_content ||= <<~RUBY
          # frozen_string_literal: true

          require 'quicken'

          module Quicken
            module Plugins
              class #{name.capitalize} < Quicken::Plugin
              end
            end
          end
        RUBY
      end

      def add_plugin_folder name
        root = "quicken-#{name}"
        filename = "lib/quicken/plugins/#{name}.rb"
        create_file "#{root}/#{filename}", plugin_file_content(name)
        FileUtils.cd root do
          system "git add #{filename}"
        end
      end
    end
  end
end
