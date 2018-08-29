require 'yaml'
require 'pp'

module Quicken
  class Parser
    def initialize recipe_path
      @recipe_path = recipe_path
      @plugins = []
    end

    def parse
      recipe = YAML.load_file(@recipe_path)
      LOGGER.debug(:parser) { "Parsed recipe #{recipe.inspect}" }
      @plugins.tap do |plugins|
        recipe.each do |step| 
          plugin_name = step.keys.first
          plugin_args = step[plugin_name]
          plugins << PluginConfiguration.new(plugin_name, plugin_args)
        end
      end
    end
  end
end
