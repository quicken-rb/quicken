# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'

module Quicken
  class PluginConfiguration
    attr_accessor :name, :args, :class

    def initialize name, args
      @name = name
      @args = process_args args
      require "quicken/plugins/#{name}"
      @class = "Quicken::Plugins::#{name.camelize}".constantize
    end

    private

    def process_args args
      args.respond_to?(:symbolize_keys) ? args.symbolize_keys : args
    end
  end
end
