module Quicken
  class Error < StandardError
    def error_name
      self.class.name
    end
  end
end