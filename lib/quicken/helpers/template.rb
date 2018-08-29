require 'erb'
require 'ostruct'
require 'quicken/error'

module Quicken
  module Helpers
    module Template
      def parse template
        @erb = ERB.new template, 0, '%<>'
      end

      def compile context
        @erb.result Context.new(context).bindings
      end

      class Context < OpenStruct
        def bindings
          binding
        end
      end
    end
  end
end