module Quicken
  class PluginConfiguration
    attr_accessor :name, :args, :class

    def initialize name, args
      @name = name
      @args = args
      require "quicken/plugins/#{name}"
      @class = "Quicken::#{name.camelize}".constantize
    end
  end
end