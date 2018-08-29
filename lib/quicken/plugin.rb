require 'quicken/helpers/base'
require 'thor'

module Quicken
  class Plugin
    include Helpers::Base
    
    protected
    
    def padding
      0
    end
  end
end