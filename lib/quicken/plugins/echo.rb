module Quicken
  class Echo < Plugin
    def initialize text
      @text = text
    end
    
    def call
      puts @text
    end
  end
end