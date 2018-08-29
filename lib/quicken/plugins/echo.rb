module Quicken
  module Plugins
    class Echo < Quicken::Plugin
      def initialize text
        @text = text
      end

      def call
        say @text
      end
    end
  end
end