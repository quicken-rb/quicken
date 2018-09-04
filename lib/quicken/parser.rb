# frozen_string_literal: true

require 'yaml'
require 'uri'

module Quicken
  class Parser
    def initialize recipe_path
      @recipe_path = recipe_path
      @plugins = []
    end

    def parse
      file = load_file(@recipe_path)
      recipe = YAML.safe_load(file)
      LOGGER.debug(:parser) { "Parsed recipe #{recipe.inspect}" }
      @plugins.tap do |plugins|
        recipe.each do |step|
          plugin_name = step.keys.first
          plugin_args = step[plugin_name]
          plugins << PluginConfiguration.new(plugin_name, plugin_args)
        end
      end
    end

    private

    def load_file path
      uri = URI(path)
      case uri.scheme
      when 'http', 'https'
        require 'net/http'
        Net::HTTP.get(uri)
      else
        File.read(uri.path)
      end
    end
  end
end
