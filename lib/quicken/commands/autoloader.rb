# frozen_string_literal: true

module Quicken
  module Commands
    Dir["#{File.expand_path(__dir__)}/*.rb"].each do |file|
      filename  = File.basename file
      classname = filename.split('.rb').first.camelize
      autoload classname, File.expand_path("../#{filename}", __FILE__)
    end
  end
end
