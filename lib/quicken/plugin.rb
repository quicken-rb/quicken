# frozen_string_literal: true

require 'quicken/helpers/base'

module Quicken
  class Plugin
    include Helpers::Base

    def initialize args
      @args = args
    end

    def call
      puts "WARNING: #{self.class.name.demodulize} not implemented"
    end

    protected

    def padding
      0
    end
  end
end
