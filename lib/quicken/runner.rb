module Quicken
  class Runner
    def initialize plugin_configurations
      @configurations = plugin_configurations
    end

    def run
      @configurations.each do |config|
        plugin = config.class.new config.args
        plugin.call
      end
    end
  end
end
